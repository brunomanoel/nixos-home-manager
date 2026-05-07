# MCP Reference — Ferramentas disponíveis

> Fonte: `/home/bruno/dotfiles/home/bruno/features/claude.nix`
> `context` e `context7` são EXCLUSIVAMENTE para docs de frameworks/libs/código.

## Ordem obrigatória para docs de frameworks/libs

```
1. mcp__context__search_packages(registry, name)
2. mcp__context__download_package(registry, name, version)
3. mcp__context__get_docs(library, topic)
4. mcp__context7__resolve-library-id + query-docs  ← fallback
```

## memory (`mcp__memory__*`)
recall · remember · search_code · get_file_context · get_dependencies · find_usages · get_symbol · project_overview · forget · consolidate · stats

## context (`mcp__context__*`) — docs de libs
search_packages(registry, name) · download_package(registry, name, version) · get_docs(library, topic)

## context7 (`mcp__context7__*`) — docs de libs (fallback)
resolve-library-id(libraryName, query) · query-docs(libraryId, query)

## serena (`mcp__serena__*`)
get_symbols_overview · find_symbol · find_referencing_symbols · replace_symbol_body · insert_after_symbol · insert_before_symbol · find_file · list_dir · search_for_pattern · think_about_collected_information · think_about_task_adherence · think_about_whether_you_are_done · read_memory · write_memory · list_memories · delete_memory · onboarding · check_onboarding_performed

## filesystem (`mcp__filesystem__*`)
read_file · read_multiple_files · read_text_file · read_media_file · write_file · edit_file · list_directory · list_directory_with_sizes · directory_tree · create_directory · move_file · search_files · get_file_info · list_allowed_directories

## git (`mcp__git__*`)
git_status · git_diff · git_diff_unstaged · git_diff_staged · git_add · git_commit · git_log · git_show · git_branch · git_checkout · git_create_branch · git_reset

## github (`mcp__github__*`)
get_me · list_pull_requests · pull_request_read · create_pull_request · update_pull_request · merge_pull_request · pull_request_review_write · add_comment_to_pending_review · add_reply_to_pull_request_comment · list_issues · issue_read · issue_write · add_issue_comment · search_pull_requests · search_issues · search_code · get_file_contents · create_or_update_file · delete_file · push_files · list_branches · create_branch · list_commits · get_commit · list_releases · get_latest_release · get_tag · list_tags · get_label · search_repositories · search_users · fork_repository · create_repository · assign_copilot_to_issue · request_copilot_review · sub_issue_write · update_pull_request_branch

## fetch (`mcp__fetch__*`)
fetch(url, method)

## sequential-thinking (`mcp__sequential-thinking__*`)
sequentialthinking(thought, thoughtNumber, totalThoughts, nextThoughtNeeded)

## nixos (`mcp__nixos__*`)
nix(query) · nix_versions(package)

## playwright (`mcp__playwright__*`)
browser_navigate · browser_snapshot · browser_take_screenshot · browser_fill_form · browser_click · browser_type · browser_evaluate · browser_wait_for · browser_network_requests · browser_console_messages · browser_tabs · browser_navigate_back · browser_resize · browser_run_code · browser_select_option · browser_drag · browser_hover · browser_press_key · browser_file_upload · browser_handle_dialog · browser_close · browser_install

## chrome-devtools (`mcp__chrome-devtools__*`)
navigate_page · take_screenshot · take_snapshot · evaluate_script · fill · fill_form · click · hover · drag · press_key · type_text · list_pages · new_page · select_page · close_page · resize_page · emulate · list_network_requests · get_network_request · list_console_messages · get_console_message · handle_dialog · upload_file · wait_for · take_memory_snapshot · performance_start_trace · performance_stop_trace · performance_analyze_insight · lighthouse_audit
