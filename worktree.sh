#!/usr/bin/env bash
# ==============================================================================
# Home Assistant Git Worktree Management Tool
# Facilitates parallel multi-agent and developer workflows across isolated worktrees.
# ==============================================================================

set -euo pipefail

MAIN_REPO_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$MAIN_REPO_DIR"

# Color helpers
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    GREEN=''
    BLUE=''
    YELLOW=''
    RED=''
    BOLD=''
    NC=''
fi

usage() {
    cat << EOF
${BOLD}Home Assistant Git Worktree Manager${NC}

Usage:
  ./worktree.sh new <name> [type]       Create a new worktree at ../ha-<name> (default type: feature)
  ./worktree.sh list                    List all active worktrees and their branches
  ./worktree.sh check-stale             Identify worktrees whose PR is merged or remote branch deleted
  ./worktree.sh clean-stale [-y]        Remove all stale worktrees (prompts for confirmation unless -y)
  ./worktree.sh remove <name-or-path>   Remove a specific worktree safely
  ./worktree.sh prune                   Prune stale worktree metadata

Examples:
  ./worktree.sh new office-presence-lighting
  ./worktree.sh new fan-watchdog fix
  ./worktree.sh check-stale
  ./worktree.sh clean-stale
  ./worktree.sh remove office-presence-lighting
EOF
}

cmd_new() {
    local name="${1:-}"
    local btype="${2:-feature}"

    if [ -z "$name" ]; then
        echo -e "${RED}Error: Worktree name required.${NC}"
        echo "Example: ./worktree.sh new office-presence-lighting"
        exit 1
    fi

    # Sanitize name
    name="$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/-/g')"
    local branch="${btype}/${name}"
    local parent_dir
    parent_dir="$(dirname "$MAIN_REPO_DIR")"
    local repo_name
    repo_name="$(basename "$MAIN_REPO_DIR")"
    local wt_path="${parent_dir}/${repo_name}-${name}"

    if [ -d "$wt_path" ]; then
        echo -e "${RED}Error: Directory already exists at ${wt_path}${NC}"
        exit 1
    fi

    if git show-ref --verify --quiet "refs/heads/${branch}"; then
        echo -e "${YELLOW}Warning: Local branch ${branch} already exists. Checking out existing branch...${NC}"
        git worktree add "$wt_path" "$branch"
    else
        echo -e "${BLUE}Fetching latest origin/main...${NC}"
        git fetch origin main --quiet || true
        echo -e "${GREEN}Creating worktree at ${wt_path} on branch ${branch}...${NC}"
        git worktree add -b "$branch" "$wt_path" origin/main
    fi

    echo ""
    echo -e "${GREEN}${BOLD}✓ Worktree ready!${NC}"
    echo -e "  Path:   ${BOLD}${wt_path}${NC}"
    echo -e "  Branch: ${BOLD}${branch}${NC}"
    echo ""
    echo -e "To start working in this worktree:"
    echo -e "  cd \"${wt_path}\""
}

cmd_list() {
    echo -e "${BOLD}Active Worktrees:${NC}"
    git worktree list | while read -r line; do
        local path branch commit
        path="$(echo "$line" | awk '{print $1}')"
        commit="$(echo "$line" | awk '{print $2}')"
        branch="$(echo "$line" | sed -E 's/^[^[]*\[([^]]*)\].*$/\1/')"

        local status_indicator="${GREEN}●${NC}"
        local is_main=""
        if [ "$path" = "$MAIN_REPO_DIR" ]; then
            is_main=" ${BLUE}(Main Repository)${NC}"
        fi

        # Check for uncommitted changes
        local dirty=""
        if [ -d "$path" ] && [ -n "$(git -C "$path" status --porcelain 2>/dev/null)" ]; then
            dirty=" ${YELLOW}[Uncommitted Changes]${NC}"
        fi

        echo -e "  ${status_indicator} ${BOLD}${path}${NC}${is_main}"
        echo -e "     Branch: ${branch} (${commit})${dirty}"
    done
}

get_stale_worktrees() {
    # Prune worktree administrative files first
    git worktree prune

    # Fetch with pruning
    git fetch -p origin --quiet 2>/dev/null || true

    # Iterate through worktrees, skipping main repo
    git worktree list --porcelain | awk '
        /^worktree / { wt = substr($0, 10) }
        /^branch /   { br = substr($0, 8); sub("refs/heads/", "", br); print wt "|" br }
    ' | while IFS="|" read -r wt branch; do
        # Never consider main repo stale
        if [ "$wt" = "$MAIN_REPO_DIR" ]; then
            continue
        fi

        local is_stale=0
        local reason=""

        # Check 1: Does remote tracking branch exist?
        if ! git show-ref --verify --quiet "refs/remotes/origin/${branch}"; then
            is_stale=1
            reason="Remote branch origin/${branch} deleted or missing"
        fi

        # Check 2: Check GitHub PR status via gh CLI if available
        if command -v gh >/dev/null 2>&1; then
            local pr_state
            pr_state="$(gh pr view "$branch" --json state -q .state 2>/dev/null || true)"
            if [ "$pr_state" = "MERGED" ]; then
                is_stale=1
                reason="GitHub PR is MERGED"
            elif [ "$pr_state" = "CLOSED" ]; then
                is_stale=1
                reason="GitHub PR is CLOSED"
            fi
        fi

        if [ "$is_stale" -eq 1 ]; then
            # Check dirty status
            local dirty="clean"
            if [ -d "$wt" ] && [ -n "$(git -C "$wt" status --porcelain 2>/dev/null)" ]; then
                dirty="dirty"
            fi
            echo "${wt}|${branch}|${reason}|${dirty}"
        fi
    done
}

cmd_check_stale() {
    echo -e "${BLUE}Checking for stale worktrees against GitHub and remote tracking...${NC}"
    local stale_entries
    stale_entries="$(get_stale_worktrees)"

    if [ -z "$stale_entries" ]; then
        echo -e "${GREEN}✓ No stale worktrees detected. All worktrees are active.${NC}"
        return 0
    fi

    echo -e "\n${YELLOW}${BOLD}Stale Worktrees Found:${NC}"
    echo "$stale_entries" | while IFS="|" read -r wt branch reason dirty; do
        local dirty_notice=""
        if [ "$dirty" = "dirty" ]; then
            dirty_notice=" ${RED}[DIRTY: Uncommitted work!]${NC}"
        fi
        echo -e "  ${RED}✖${NC} ${BOLD}${wt}${NC}"
        echo -e "     Branch: ${branch}"
        echo -e "     Reason: ${reason}${dirty_notice}"
    done
    echo ""
    echo -e "Run ${BOLD}./worktree.sh clean-stale${NC} to safely remove these worktrees."
}

remove_single_worktree() {
    local target="$1"
    local force_flag="${2:-0}"

    local wt_path=""
    if [ -d "$target" ]; then
        wt_path="$(cd "$target" && pwd)"
    else
        local parent_dir
        parent_dir="$(dirname "$MAIN_REPO_DIR")"
        local repo_name
        repo_name="$(basename "$MAIN_REPO_DIR")"
        if [ -d "${parent_dir}/${repo_name}-${target}" ]; then
            wt_path="${parent_dir}/${repo_name}-${target}"
        elif [ -d "${parent_dir}/${target}" ]; then
            wt_path="${parent_dir}/${target}"
        fi
    fi

    if [ -z "$wt_path" ] || [ ! -d "$wt_path" ]; then
        echo -e "${RED}Error: Worktree '${target}' not found.${NC}"
        return 1
    fi

    if [ "$wt_path" = "$MAIN_REPO_DIR" ]; then
        echo -e "${RED}Error: Refusing to remove main repository (${MAIN_REPO_DIR}).${NC}"
        return 1
    fi

    # Check for uncommitted work
    if [ -n "$(git -C "$wt_path" status --porcelain 2>/dev/null)" ] && [ "$force_flag" -ne 1 ]; then
        echo -e "${RED}Error: Worktree ${wt_path} contains uncommitted changes. Use force to delete.${NC}"
        return 1
    fi

    # Determine branch before removal
    local branch
    branch="$(git -C "$wt_path" branch --show-current 2>/dev/null || true)"

    echo -e "${YELLOW}Removing worktree: ${wt_path}...${NC}"
    if [ "$force_flag" -eq 1 ]; then
        git worktree remove --force "$wt_path"
    else
        git worktree remove "$wt_path"
    fi

    # Delete local branch if merged or if requested
    if [ -n "$branch" ] && [ "$branch" != "main" ]; then
        if git branch -d "$branch" 2>/dev/null; then
            echo -e "${GREEN}✓ Deleted local branch ${branch}.${NC}"
        else
            echo -e "${YELLOW}Note: Local branch ${branch} retained (or use 'git branch -D ${branch}').${NC}"
        fi
    fi

    git worktree prune
    echo -e "${GREEN}✓ Successfully removed worktree.${NC}"
}

cmd_clean_stale() {
    local auto_yes=0
    if [ "${1:-}" = "-y" ] || [ "${1:-}" = "--yes" ]; then
        auto_yes=1
    fi

    local stale_entries
    stale_entries="$(get_stale_worktrees)"

    if [ -z "$stale_entries" ]; then
        echo -e "${GREEN}✓ No stale worktrees to clean.${NC}"
        return 0
    fi

    echo -e "${YELLOW}${BOLD}The following stale worktrees will be removed:${NC}"
    echo "$stale_entries" | while IFS="|" read -r wt branch reason dirty; do
        echo -e "  - ${wt} (${branch}) [${reason}]"
        if [ "$dirty" = "dirty" ]; then
            echo -e "    ${RED}WARNING: Contains uncommitted changes!${NC}"
        fi
    done
    echo ""

    if [ "$auto_yes" -ne 1 ]; then
        read -r -p "Do you want to proceed with removing these worktrees? (y/N) " confirm
        case "$confirm" in
            [yY][eE][sS]|[yY])
                ;;
            *)
                echo "Aborted."
                return 0
                ;;
        esac
    fi

    echo "$stale_entries" | while IFS="|" read -r wt branch reason dirty; do
        if [ -d "$wt" ]; then
            local force=0
            if [ "$dirty" = "dirty" ]; then
                force=1
            fi
            remove_single_worktree "$wt" "$force"
        fi
    done

    echo -e "\n${GREEN}${BOLD}✓ Stale worktree cleanup complete.${NC}"
}

# Main command dispatch
COMMAND="${1:-}"
case "$COMMAND" in
    new)
        shift
        cmd_new "$@"
        ;;
    list|ls)
        cmd_list
        ;;
    check-stale|check)
        cmd_check_stale
        ;;
    clean-stale)
        shift
        cmd_clean_stale "$@"
        ;;
    remove|rm|clean)
        shift
        if [ -z "${1:-}" ]; then
            echo -e "${RED}Error: Specify a worktree name or path to remove.${NC}"
            exit 1
        fi
        remove_single_worktree "$1" "${2:-0}"
        ;;
    prune)
        git worktree prune
        echo -e "${GREEN}✓ Worktrees pruned.${NC}"
        ;;
    -h|--help|help|"")
        usage
        ;;
    *)
        echo -e "${RED}Unknown command: ${COMMAND}${NC}"
        usage
        exit 1
        ;;
esac
