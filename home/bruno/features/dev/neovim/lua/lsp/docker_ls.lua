-- docker-language-server: handles Dockerfile, docker-compose, and Bake files
vim.lsp.config('docker_language_server', {
    cmd = { 'docker-language-server', 'start', '--stdio' },
    filetypes = { 'dockerfile', 'yaml.docker-compose', 'hcl.bake' },
    root_markers = { 'Dockerfile', 'docker-compose.yml', 'docker-compose.yaml', 'compose.yml', 'compose.yaml', '.git' },
})
vim.lsp.enable('docker_language_server')
