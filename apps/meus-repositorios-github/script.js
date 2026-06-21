
/* Melhorias de UX/Perf/A11y
 - Botão de Download integrado ao header já suportado em downloadRepository()
 - Tema: sincroniza ícone e aria-pressed; ciclo light/dark/auto
 - Repositórios: clique no cartão seleciona para download; enter/space aciona
 - Debounce utilitário compartilhado; throttling para scroll
*/



 // Estado global da aplicação
const app = {
    selectedFiles: [],
    credentials: null,
    logs: [],
    currentSection: 'main-menu',
    repositories: [],
    userInfo: null,
    dashboardData: null,
    settings: {
        autoGitignore: true,
        autoReadme: true,
        compressImages: false,
        maxFileSize: 25,
        defaultBranch: 'main',
        autoCommitMessage: true,
        commitPrefix: '✨ ',
        scanSecrets: true,
        encryptCredentials: true,
        sessionTimeout: 60,
        theme: 'light',
        language: 'pt-BR',
        animations: true,
        autoSync: false,
        syncInterval: 30
    },
    selectedTemplate: null,
    templates: {
        'web-basic': {
            name: 'Site Básico',
            description: 'HTML, CSS e JavaScript básico',
            files: {
                'index.html': '<!DOCTYPE html>\n<html lang="pt-BR">\n<head>\n    <meta charset="UTF-8">\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\n    <title>Meu Site</title>\n    <link rel="stylesheet" href="style.css">\n</head>\n<body>\n    <h1>Bem-vindo ao meu site!</h1>\n    <script src="script.js"></script>\n</body>\n</html>',
                'style.css': 'body {\n    font-family: Arial, sans-serif;\n    margin: 0;\n    padding: 20px;\n    background: #f5f5f5;\n}\n\nh1 {\n    color: #333;\n    text-align: center;\n}',
                'script.js': 'console.log("Site carregado com sucesso!");'
            }
        },
        'react-app': {
            name: 'React App',
            description: 'Aplicação React com estrutura completa',
            files: {
                'package.json': '{\n  "name": "minha-app-react",\n  "version": "1.0.0",\n  "dependencies": {\n    "react": "^18.0.0",\n    "react-dom": "^18.0.0"\n  },\n  "scripts": {\n    "start": "react-scripts start",\n    "build": "react-scripts build"\n  }\n}',
                'src/App.js': 'import React from "react";\nimport "./App.css";\n\nfunction App() {\n  return (\n    <div className="App">\n      <h1>Minha App React</h1>\n      <p>Bem-vindo à sua nova aplicação!</p>\n    </div>\n  );\n}\n\nexport default App;',
                'src/App.css': '.App {\n  text-align: center;\n  padding: 20px;\n}\n\nh1 {\n  color: #61dafb;\n}',
                'public/index.html': '<!DOCTYPE html>\n<html>\n<head>\n    <title>React App</title>\n</head>\n<body>\n    <div id="root"></div>\n</body>\n</html>'
            }
        },
        'python-flask': {
            name: 'Flask API',
            description: 'API REST com Python e Flask',
            files: {
                'app.py': 'from flask import Flask, jsonify\n\napp = Flask(__name__)\n\n@app.route("/")\ndef home():\n    return jsonify({"message": "Bem-vindo à minha API Flask!"})\n\n@app.route("/api/status")\ndef status():\n    return jsonify({"status": "OK", "version": "1.0.0"})\n\nif __name__ == "__main__":\n    app.run(debug=True, host="0.0.0.0", port=5000)',
                'requirements.txt': 'Flask==2.3.3\nFlask-CORS==4.0.0',
                'config.py': 'import os\n\nclass Config:\n    SECRET_KEY = os.environ.get("SECRET_KEY") or "dev-secret-key"\n    DEBUG = True'
            }
        },
        'node-express': {
            name: 'Node.js + Express',
            description: 'Servidor backend com Express',
            files: {
                'package.json': '{\n  "name": "meu-servidor-express",\n  "version": "1.0.0",\n  "main": "server.js",\n  "dependencies": {\n    "express": "^4.18.0",\n    "cors": "^2.8.5"\n  },\n  "scripts": {\n    "start": "node server.js",\n    "dev": "nodemon server.js"\n  }\n}',
                'server.js': 'const express = require("express");\nconst cors = require("cors");\n\nconst app = express();\nconst PORT = process.env.PORT || 5000;\n\napp.use(cors());\napp.use(express.json());\n\napp.get("/", (req, res) => {\n  res.json({ message: "Servidor Express funcionando!" });\n});\n\napp.get("/api/status", (req, res) => {\n  res.json({ status: "OK", timestamp: new Date().toISOString() });\n});\n\napp.listen(PORT, "0.0.0.0", () => {\n  console.log(`Servidor rodando na porta ${PORT}`);\n});'
            }
        },
        'portfolio': {
            name: 'Portfólio',
            description: 'Site portfólio responsivo',
            files: {
                'index.html': '<!DOCTYPE html>\n<html lang="pt-BR">\n<head>\n    <meta charset="UTF-8">\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\n    <title>Meu Portfólio</title>\n    <link rel="stylesheet" href="style.css">\n</head>\n<body>\n    <nav>\n        <h1>Meu Nome</h1>\n        <ul>\n            <li><a href="#sobre">Sobre</a></li>\n            <li><a href="#projetos">Projetos</a></li>\n            <li><a href="#contato">Contato</a></li>\n        </ul>\n    </nav>\n    \n    <section id="hero">\n        <h2>Desenvolvedor Full Stack</h2>\n        <p>Criando soluções digitais incríveis</p>\n    </section>\n    \n    <section id="sobre">\n        <h2>Sobre Mim</h2>\n        <p>Desenvolvedor apaixonado por tecnologia...</p>\n    </section>\n    \n    <section id="projetos">\n        <h2>Meus Projetos</h2>\n        <div class="projetos-grid">\n            <div class="projeto">\n                <h3>Projeto 1</h3>\n                <p>Descrição do projeto...</p>\n            </div>\n        </div>\n    </section>\n    \n    <footer id="contato">\n        <h2>Contato</h2>\n        <p>email@exemplo.com</p>\n    </footer>\n</body>\n</html>',
                'style.css': '* {\n    margin: 0;\n    padding: 0;\n    box-sizing: border-box;\n}\n\nbody {\n    font-family: Arial, sans-serif;\n    line-height: 1.6;\n    color: #333;\n}\n\nnav {\n    background: #333;\n    color: white;\n    padding: 1rem;\n    display: flex;\n    justify-content: space-between;\n    align-items: center;\n}\n\nnav ul {\n    display: flex;\n    list-style: none;\n    gap: 2rem;\n}\n\nnav a {\n    color: white;\n    text-decoration: none;\n}\n\n#hero {\n    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);\n    color: white;\n    text-align: center;\n    padding: 5rem 2rem;\n}\n\nsection {\n    padding: 3rem 2rem;\n    max-width: 1200px;\n    margin: 0 auto;\n}\n\n.projetos-grid {\n    display: grid;\n    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));\n    gap: 2rem;\n    margin-top: 2rem;\n}\n\n.projeto {\n    background: #f4f4f4;\n    padding: 2rem;\n    border-radius: 8px;\n}\n\nfooter {\n    background: #333;\n    color: white;\n    text-align: center;\n    padding: 2rem;\n}'
            }
        },
        'documentation': {
            name: 'Documentação',
            description: 'Site de documentação com Markdown',
            files: {
                'index.html': '<!DOCTYPE html>\n<html lang="pt-BR">\n<head>\n    <meta charset="UTF-8">\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\n    <title>Documentação</title>\n    <link rel="stylesheet" href="style.css">\n</head>\n<body>\n    <nav class="sidebar">\n        <h1>Documentação</h1>\n        <ul>\n            <li><a href="#introducao">Introdução</a></li>\n            <li><a href="#instalacao">Instalação</a></li>\n            <li><a href="#uso">Como Usar</a></li>\n            <li><a href="#api">Referência API</a></li>\n        </ul>\n    </nav>\n    \n    <main class="content">\n        <section id="introducao">\n            <h1>Introdução</h1>\n            <p>Bem-vindo à documentação do projeto...</p>\n        </section>\n        \n        <section id="instalacao">\n            <h1>Instalação</h1>\n            <pre><code>npm install meu-projeto</code></pre>\n        </section>\n        \n        <section id="uso">\n            <h1>Como Usar</h1>\n            <p>Exemplo básico de uso...</p>\n        </section>\n        \n        <section id="api">\n            <h1>Referência API</h1>\n            <p>Documentação completa da API...</p>\n        </section>\n    </main>\n</body>\n</html>',
                'style.css': '* {\n    margin: 0;\n    padding: 0;\n    box-sizing: border-box;\n}\n\nbody {\n    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;\n    display: flex;\n    min-height: 100vh;\n}\n\n.sidebar {\n    width: 250px;\n    background: #2c3e50;\n    color: white;\n    padding: 2rem;\n    position: fixed;\n    height: 100vh;\n    overflow-y: auto;\n}\n\n.sidebar h1 {\n    margin-bottom: 2rem;\n    color: #3498db;\n}\n\n.sidebar ul {\n    list-style: none;\n}\n\n.sidebar li {\n    margin-bottom: 1rem;\n}\n\n.sidebar a {\n    color: #ecf0f1;\n    text-decoration: none;\n    padding: 0.5rem;\n    display: block;\n    border-radius: 4px;\n    transition: background 0.3s;\n}\n\n.sidebar a:hover {\n    background: #34495e;\n}\n\n.content {\n    margin-left: 250px;\n    padding: 2rem;\n    max-width: 800px;\n    line-height: 1.6;\n}\n\n.content h1 {\n    color: #2c3e50;\n    margin-bottom: 1rem;\n    border-bottom: 2px solid #3498db;\n    padding-bottom: 0.5rem;\n}\n\n.content p {\n    margin-bottom: 1rem;\n}\n\npre {\n    background: #f8f9fa;\n    padding: 1rem;\n    border-radius: 4px;\n    overflow-x: auto;\n    margin: 1rem 0;\n}\n\ncode {\n    background: #f8f9fa;\n    padding: 0.2rem 0.4rem;\n    border-radius: 3px;\n    font-family: "Courier New", monospace;\n}',
                'README.md': '# Documentação do Projeto\n\n## Sobre\n\nEsta é a documentação completa do projeto.\n\n## Estrutura\n\n- `index.html` - Página principal\n- `style.css` - Estilos da documentação\n- `README.md` - Este arquivo\n\n## Como contribuir\n\n1. Fork o projeto\n2. Crie uma branch para sua feature\n3. Commit suas mudanças\n4. Push para a branch\n5. Abra um Pull Request'
            }
        }
    }
};

// Inicialização
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();

    // Acessibilidade: navegação por teclado para botões principais
    document.querySelectorAll('button, a, [role="button"]').forEach(el => {
        el.addEventListener('keyup', (e) => {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                e.target.click();
            }
        });
    });

    // Melhor UX: habilitar atalho "s" para focar busca nos repositórios
    document.addEventListener('keydown', (e) => {
        if (e.key.toLowerCase() === 's' && app.currentSection === 'repos-section' && !['INPUT','TEXTAREA','SELECT'].includes(document.activeElement.tagName)) {
            const input = document.getElementById('repo-search');
            if (input) {
                input.focus();
                e.preventDefault();
            }
        }
    });

    // Throttle de rolagem para evitar trabalho excessivo
    // const onScroll = throttle(() => {
    //     // reservado para futuras leituras de posição sem repaints
    // }, 150);
    // window.addEventListener('scroll', onScroll, { passive: true });
});

function initializeApp() {
    loadCredentials();
    loadLogs();
    setupFileUpload();
    runSystemCheck();
    updateConnectionStatus();
    
    // Log de inicialização
    addLog('info', 'Sistema inicializado com sucesso');
}

/* Gerenciamento de seções */
function showSection(sectionId) {
    // Evitar retrabalho se já estiver na seção
    if (app.currentSection === sectionId) return;

    // Esconder todas as seções e aplicar inert para acessibilidade
    const sections = document.querySelectorAll('.section, .menu-section');
    sections.forEach(section => {
        section.classList.remove('active');
        section.style.display = 'none';
        section.setAttribute('aria-hidden', 'true');
        section.setAttribute('inert', '');
    });
    
    // Mostrar seção selecionada
    const targetSection = document.getElementById(sectionId);
    if (targetSection) {
        targetSection.style.display = 'block';
        targetSection.classList.add('active');
        targetSection.setAttribute('aria-hidden', 'false');
        targetSection.removeAttribute('inert');
        app.currentSection = sectionId;

        // Enviar foco para o título da seção para acessibilidade
        const focusableHeading = targetSection.querySelector('h2, h1');
        if (focusableHeading) {
            focusableHeading.setAttribute('tabindex', '-1');
            // usar rAF para garantir render antes do foco
            requestAnimationFrame(() => {
                try { focusableHeading.focus({ preventScroll: false }); } catch(e) {}
            });
        }
    }
    
    // Ações específicas por seção
    switch (sectionId) {
        case 'verify-section':
            runSystemCheck();
            break;
        case 'logs-section':
            displayLogs();
            break;
        case 'config-section':
            loadSavedCredentials();
            break;
        case 'repos-section':
            loadRepositories();
            break;
        case 'dashboard-section':
            loadDashboard();
            break;
    }
}

// Configuração do upload de arquivos
function setupFileUpload() {
    const uploadArea = document.getElementById('upload-area');
    const fileInput = document.getElementById('file-input');
    
    // Eventos de drag and drop
    uploadArea.addEventListener('dragover', function(e) {
        e.preventDefault();
        uploadArea.classList.add('dragover');
    });
    
    uploadArea.addEventListener('dragleave', function(e) {
        e.preventDefault();
        uploadArea.classList.remove('dragover');
    });
    
    uploadArea.addEventListener('drop', function(e) {
        e.preventDefault();
        uploadArea.classList.remove('dragover');
        
        const files = Array.from(e.dataTransfer.files);
        handleFileSelection(files);
    });
    
    // Evento de clique
    uploadArea.addEventListener('click', function() {
        this.style.transform = 'scale(0.98)';
        setTimeout(() => {
            this.style.transform = '';
        }, 150);
        fileInput.click();
    });
    
    // Evento de seleção de arquivo
    fileInput.addEventListener('change', function() {
        const files = Array.from(this.files);
        handleFileSelection(files);
    });
}

function handleFileSelection(files) {
    app.selectedFiles = files;
    displaySelectedFiles();
    
    // Sugerir nome do repositório baseado no primeiro arquivo/pasta
    if (files.length > 0) {
        const firstPath = files[0].webkitRelativePath || files[0].name;
        const folderName = firstPath.split('/')[0];
        const repoNameInput = document.getElementById('repo-name');
        if (!repoNameInput.value) {
            repoNameInput.value = folderName.toLowerCase().replace(/[^a-z0-9-]/g, '-');
        }
    }
    
    // Habilitar botão de upload
    const uploadBtn = document.getElementById('upload-btn');
    uploadBtn.disabled = files.length === 0;
    
    addLog('info', `${files.length} arquivos selecionados`);
}

function displaySelectedFiles() {
    const fileList = document.getElementById('file-list');
    const filesPreview = document.getElementById('files-preview');
    
    if (app.selectedFiles.length === 0) {
        fileList.style.display = 'none';
        return;
    }
    
    fileList.style.display = 'block';
    filesPreview.innerHTML = '';
    
    // Agrupar arquivos por tipo
    const fileTypes = {};
    let totalSize = 0;
    
    app.selectedFiles.forEach(file => {
        const ext = file.name.split('.').pop().toLowerCase();
        if (!fileTypes[ext]) {
            fileTypes[ext] = { count: 0, size: 0 };
        }
        fileTypes[ext].count++;
        fileTypes[ext].size += file.size;
        totalSize += file.size;
    });
    
    // Exibir resumo
    const summary = document.createElement('div');
    summary.className = 'files-summary';
    summary.innerHTML = `
        <p><strong>Total:</strong> ${app.selectedFiles.length} arquivos (${formatFileSize(totalSize)})</p>
    `;
    filesPreview.appendChild(summary);
    
    // Exibir tipos de arquivo
    Object.entries(fileTypes).forEach(([ext, info]) => {
        const fileItem = document.createElement('div');
        fileItem.className = 'file-item';
        fileItem.innerHTML = `
            <i class="fas fa-file"></i>
            <span>.${ext} files: ${info.count} (${formatFileSize(info.size)})</span>
        `;
        filesPreview.appendChild(fileItem);
    });
    
    // Mostrar alguns arquivos individuais se houver poucos
    if (app.selectedFiles.length <= 10) {
        const separator = document.createElement('hr');
        separator.style.margin = '15px 0';
        filesPreview.appendChild(separator);
        
        app.selectedFiles.forEach(file => {
            const fileItem = document.createElement('div');
            fileItem.className = 'file-item';
            fileItem.innerHTML = `
                <i class="fas fa-file"></i>
                <span>${file.webkitRelativePath || file.name} (${formatFileSize(file.size)})</span>
            `;
            filesPreview.appendChild(fileItem);
        });
    }
}

function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// Credenciais
function saveCredentials() {
    const token = document.getElementById('github-token').value.trim();
    const username = document.getElementById('github-username').value.trim();
    
    if (!token || !username) {
        showNotification('Preencha todos os campos', 'error');
        return;
    }

    // Feedback de carregamento no botão
    const btn = document.getElementById('save-credentials-btn');
    if (btn) {
        btn.setAttribute('aria-busy', 'true');
        btn.disabled = true;
    }
    
    app.credentials = { token, username };
    localStorage.setItem('git-automatico-credentials', JSON.stringify(app.credentials));
    
    showNotification('Credenciais salvas com sucesso!', 'success');
    updateConnectionStatus();
    addLog('info', 'Credenciais atualizadas');

    if (btn) {
        btn.setAttribute('aria-busy', 'false');
        btn.disabled = false;
    }
}

function loadCredentials() {
    const saved = localStorage.getItem('git-automatico-credentials');
    if (saved) {
        app.credentials = JSON.parse(saved);
        updateConnectionStatus();
    }
}

function loadSavedCredentials() {
    if (app.credentials) {
        document.getElementById('github-token').value = app.credentials.token;
        document.getElementById('github-username').value = app.credentials.username;
    }
}

async function testCredentials() {
    if (!app.credentials) {
        showNotification('Configure as credenciais primeiro', 'warning');
        return;
    }
    
    try {
        showNotification('Testando conexão...', 'info');
        
        const response = await fetch('https://api.github.com/user', {
            headers: {
                'Authorization': `token ${app.credentials.token}`,
                'Accept': 'application/vnd.github.v3+json'
            }
        });
        
        if (response.ok) {
            const user = await response.json();
            showNotification(`Conectado como ${user.login}`, 'success');
            addLog('success', `Autenticação bem-sucedida para ${user.login}`);
            updateConnectionStatus(true);
        } else {
            const msg = response.status === 401 ? 'Token inválido ou expirado' : 'Falha na autenticação';
            showNotification(msg, 'error');
            addLog('error', `${msg} (HTTP ${response.status})`);
            updateConnectionStatus(false);
        }
    } catch (error) {
        showNotification('Erro de conexão', 'error');
        addLog('error', `Erro de conexão: ${error.message}`);
        updateConnectionStatus(false);
    }
}

// Upload do projeto
async function uploadProject() {
    if (!app.credentials) {
        showNotification('Configure as credenciais primeiro', 'error');
        showSection('config-section');
        return;
    }
    
    if (app.selectedFiles.length === 0) {
        showNotification('Selecione os arquivos primeiro', 'error');
        return;
    }
    
    const repoName = document.getElementById('repo-name').value.trim();
    const repoDescription = document.getElementById('repo-description').value.trim();
    const isPrivate = document.getElementById('private-repo').checked;
    
    if (!repoName) {
        showNotification('Insira o nome do repositório', 'error');
        return;
    }
    
    // Validar nome do repositório
    if (!/^[a-zA-Z0-9._-]+$/.test(repoName)) {
        showNotification('Nome do repositório deve conter apenas letras, números, pontos, hífens e underscores', 'error');
        return;
    }
    
    try {
        showProgressSection(true);
        updateProgress(10, 'Criando repositório...');
        addLog('info', `Iniciando upload do projeto: ${repoName}`);
        
        // Criar repositório
        const repo = await createRepository(repoName, repoDescription, isPrivate);
        updateProgress(30, 'Repositório criado! Preparando arquivos...');
        addLog('success', `Repositório ${repoName} criado com sucesso`);
        
        // Preparar arquivos
        const files = await prepareFiles();
        updateProgress(50, 'Enviando arquivos...');
        
        // Enviar arquivos
        await uploadFiles(repo, files);
        updateProgress(90, 'Finalizando...');
        
        updateProgress(100, 'Concluído!');
        addLog('success', `Projeto enviado com sucesso para: ${repo.html_url}`);
        
        setTimeout(() => {
            showNotification(`Projeto enviado! <a href="${repo.html_url}" target="_blank">Ver no GitHub</a>`, 'success');
            showProgressSection(false);
            resetUploadForm();
        }, 1000);
        
    } catch (error) {
        addLog('error', `Erro no upload: ${error.message}`);
        showNotification(`Erro: ${error.message}`, 'error');
        showProgressSection(false);
    }
}

async function createRepository(name, description, isPrivate) {
    const response = await fetch('https://api.github.com/user/repos', {
        method: 'POST',
        headers: {
            'Authorization': `token ${app.credentials.token}`,
            'Accept': 'application/vnd.github.v3+json',
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            name: name,
            description: description || `Projeto criado com Git Automático Web`,
            private: isPrivate,
            auto_init: true
        })
    });
    
    if (!response.ok) {
        let error;
        try {
            error = await response.json();
        } catch {
            error = {};
        }
        if (response.status === 422 && (error?.errors?.some(e => String(e.message || '').includes('already exists')) || String(error?.message || '').includes('already exists'))) {
            throw new Error(`Repositório "${name}" já existe. Use um nome diferente.`);
        }
        if (response.status === 401) {
            throw new Error('Não autorizado. Verifique o token do GitHub.');
        }
        throw new Error(error?.message || 'Erro ao criar repositório');
    }
    
    return await response.json();
}

async function prepareFiles() {
    const files = {};
    
    for (const file of app.selectedFiles) {
        const path = file.webkitRelativePath || file.name;
        
        // Pular arquivos muito grandes (>25MB - limite do GitHub)
        if (file.size > 25 * 1024 * 1024) {
            addLog('warning', `Arquivo ${path} muito grande (${formatFileSize(file.size)}) - pulando`);
            continue;
        }
        
        // Pular arquivos binários comuns que não precisam estar no repo
        const skipExtensions = ['.exe', '.dll', '.so', '.dylib', '.bin'];
        const ext = path.split('.').pop().toLowerCase();
        if (skipExtensions.includes(`.${ext}`)) {
            addLog('info', `Pulando arquivo binário: ${path}`);
            continue;
        }
        
        try {
            const content = await readFileAsBase64(file);
            files[path] = {
                content: content,
                encoding: 'base64'
            };
        } catch (error) {
            addLog('warning', `Erro ao ler arquivo ${path}: ${error.message}`);
        }
    }
    
    // Criar .gitignore se não existir
    if (!files['.gitignore']) {
        files['.gitignore'] = {
            content: btoa(generateGitignore()),
            encoding: 'base64'
        };
    }
    
    return files;
}

function readFileAsBase64(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => {
            const base64 = reader.result.split(',')[1];
            resolve(base64);
        };
        reader.onerror = reject;
        reader.readAsDataURL(file);
    });
}

async function uploadFiles(repo, files) {
    const fileEntries = Object.entries(files);
    const batchSize = 5; // Enviar 5 arquivos por vez
    let uploaded = 0;

    for (let i = 0; i < fileEntries.length; i += batchSize) {
        const batch = fileEntries.slice(i, i + batchSize);
        const results = await Promise.allSettled(
            batch.map(([path, fileData]) => uploadSingleFile(repo, path, fileData))
        );

        // Contabilizar sucesso/erro do batch
        results.forEach((res, idx) => {
            const fileName = batch[idx][0];
            if (res.status === 'fulfilled') {
                uploaded++;
            } else {
                addLog('error', `Falha ao enviar: ${fileName} - ${res.reason?.message || res.reason}`);
            }
        });
        
        const progress = 50 + (uploaded / fileEntries.length) * 40;
        updateProgress(progress, `Enviando arquivos... (${uploaded}/${fileEntries.length})`);
        
        // Pausa breve para não sobrecarregar a API
        if (i + batchSize < fileEntries.length) {
            await new Promise(resolve => setTimeout(resolve, 250));
        }
    }

    // Mensagem final de resumo
    addLog('info', `Upload finalizado: ${uploaded}/${fileEntries.length} arquivos enviados`);
}

async function uploadSingleFile(repo, path, fileData) {
    // Retry com backoff exponencial simples + respeito a X-RateLimit-Reset
    const maxRetries = 3;
    for (let attempt = 0; attempt <= maxRetries; attempt++) {
        const response = await fetch(`https://api.github.com/repos/${repo.full_name}/contents/${encodeURIComponent(path)}`, {
            method: 'PUT',
            headers: {
                'Authorization': `token ${app.credentials.token}`,
                'Accept': 'application/vnd.github.v3+json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                message: `${app.settings.autoCommitMessage ? app.settings.commitPrefix : ''}Add ${path}`,
                content: fileData.content,
                encoding: fileData.encoding,
                branch: app.settings.defaultBranch || 'main'
            })
        });
        
        if (response.ok) {
            addLog('info', `Arquivo enviado: ${path}`);
            return;
        }

        // Lidar com rate limit
        if (response.status === 403) {
            const reset = response.headers.get('X-RateLimit-Reset');
            if (reset) {
                const waitMs = Math.max(0, parseInt(reset, 10) * 1000 - Date.now());
                if (waitMs > 0 && attempt < maxRetries) {
                    addLog('warning', `Rate limit atingido. Aguardando ${Math.ceil(waitMs/1000)}s antes de tentar novamente...`);
                    await new Promise(r => setTimeout(r, Math.min(waitMs, 15000))); // aguarda até 15s
                    continue;
                }
            }
        }

        // 429/5xx -> tentar novamente com backoff
        if ([429, 500, 502, 503, 504].includes(response.status) && attempt < maxRetries) {
            const wait = 500 * Math.pow(2, attempt);
            await new Promise(r => setTimeout(r, wait));
            continue;
        }

        // Outras falhas: lançar erro detalhado
        let errorText = 'Erro ao enviar arquivo';
        try {
            const error = await response.json();
            errorText = error.message || errorText;
        } catch {}
        throw new Error(`Erro ao enviar ${path}: ${errorText} (HTTP ${response.status})`);
    }
}

function generateGitignore() {
    return `# Git Automatico Web - Gitignore Automático
# Arquivos de sistema
.DS_Store
Thumbs.db
*.log

# Dependências
node_modules/
vendor/
venv/
env/

# Arquivos de build
dist/
build/
*.min.js
*.min.css

# IDEs
.vscode/
.idea/
*.swp
*.swo

# Temporários
*.tmp
*.temp
`;
}

// Interface de progresso
function showProgressSection(show) {
    const progressSection = document.getElementById('progress-section');
    progressSection.style.display = show ? 'block' : 'none';
}

function updateProgress(percent, text) {
    const progressFill = document.getElementById('progress-fill');
    const progressText = document.getElementById('progress-text');
    
    progressFill.style.width = `${percent}%`;
    progressText.textContent = text;
}

function resetUploadForm() {
    app.selectedFiles = [];
    document.getElementById('repo-name').value = '';
    document.getElementById('repo-description').value = '';
    document.getElementById('private-repo').checked = false;
    document.getElementById('file-list').style.display = 'none';
    document.getElementById('upload-btn').disabled = true;
}

// Sistema de verificação
async function runSystemCheck() {
    const checks = {
        'browser-status': checkBrowserCompatibility,
        'github-connection': checkGitHubConnection,
        'credentials-status': checkCredentials,
        'fileapi-status': checkFileAPISupport
    };
    
    for (const [elementId, checkFunction] of Object.entries(checks)) {
        const element = document.getElementById(elementId);
        element.textContent = 'Verificando...';
        element.className = 'verify-status';
        
        try {
            const result = await checkFunction();
            element.textContent = result.message;
            element.className = `verify-status ${result.status}`;
        } catch (error) {
            element.textContent = `Erro: ${error.message}`;
            element.className = 'verify-status error';
        }
    }
}

function checkBrowserCompatibility() {
    const isCompatible = 
        window.File && 
        window.FileReader && 
        window.FileList && 
        window.Blob &&
        window.fetch;
    
    return {
        status: isCompatible ? 'success' : 'error',
        message: isCompatible ? '✅ Compatível' : '❌ Navegador não suportado'
    };
}

async function checkGitHubConnection() {
    try {
        const response = await fetch('https://api.github.com/octocat', {
            method: 'GET',
            mode: 'cors'
        });
        
        return {
            status: response.ok ? 'success' : 'error',
            message: response.ok ? '✅ Conectado' : '❌ Sem conexão'
        };
    } catch (error) {
        return {
            status: 'error',
            message: '❌ Erro de rede'
        };
    }
}

function checkCredentials() {
    const hasCredentials = app.credentials && app.credentials.token && app.credentials.username;
    
    return {
        status: hasCredentials ? 'success' : 'warning',
        message: hasCredentials ? '✅ Configuradas' : '⚠️ Não configuradas'
    };
}

function checkFileAPISupport() {
    const hasSupport = 'webkitdirectory' in document.createElement('input');
    
    return {
        status: hasSupport ? 'success' : 'warning',
        message: hasSupport ? '✅ Suportado' : '⚠️ Limitado'
    };
}

// Status de conexão
function updateConnectionStatus(connected = null) {
    const connectionStatus = document.getElementById('connection-status');
    const githubStatus = document.getElementById('github-status');

    // Status de internet
    const online = navigator.onLine;
    connectionStatus.className = `status-item ${online ? 'online' : 'offline'}`;
    connectionStatus.innerHTML = `<i class="fas fa-wifi"></i><span>${online ? 'Online' : 'Offline'}</span>`;
    
    // Status do GitHub
    if (connected === true) {
        githubStatus.className = 'status-item online';
        githubStatus.innerHTML = '<i class="fab fa-github"></i><span>GitHub: Conectado</span>';
    } else if (connected === false) {
        githubStatus.className = 'status-item offline';
        githubStatus.innerHTML = '<i class="fab fa-github"></i><span>GitHub: Erro</span>';
    } else if (app.credentials) {
        githubStatus.className = 'status-item';
        githubStatus.innerHTML = '<i class="fab fa-github"></i><span>GitHub: Configurado</span>';
    } else {
        githubStatus.className = 'status-item';
        githubStatus.innerHTML = '<i class="fab fa-github"></i><span>GitHub: Não configurado</span>';
    }
}

// Sistema de logs
function addLog(level, message) {
    const timestamp = new Date().toLocaleString('pt-BR');
    const logEntry = {
        timestamp,
        level,
        message
    };
    
    app.logs.unshift(logEntry);
    
    // Manter apenas os últimos 200 logs para histórico maior
    if (app.logs.length > 200) {
        app.logs = app.logs.slice(0, 200);
    }
    
    // Persistir de forma debounced para reduzir operações no localStorage
    debounceSaveLogs();
    
    // Atualizar display se estiver na seção de logs
    if (app.currentSection === 'logs-section') {
        displayLogs();
    }
}

function displayLogs() {
    const logsContent = document.getElementById('logs-content');
    
    if (app.logs.length === 0) {
        logsContent.innerHTML = '<div class="log-entry info">Nenhum log disponível</div>';
        return;
    }
    
    logsContent.innerHTML = app.logs
        .map(log => `<div class="log-entry ${log.level}">[${log.timestamp}] [${log.level.toUpperCase()}] ${log.message}</div>`)
        .join('');
}

function clearLogs() {
    if (confirm('Deseja realmente limpar todos os logs?')) {
        app.logs = [];
        saveLogs();
        displayLogs();
        addLog('info', 'Logs limpos pelo usuário');
    }
}

function downloadLogs() {
    const logsText = app.logs
        .map(log => `[${log.timestamp}] [${log.level.toUpperCase()}] ${log.message}`)
        .join('\n');
    
    const blob = new Blob([logsText], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    
    const a = document.createElement('a');
    a.href = url;
    a.download = `git-automatico-logs-${new Date().toISOString().split('T')[0]}.txt`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    
    addLog('info', 'Logs baixados');
}

function saveLogs() {
    localStorage.setItem('git-automatico-logs', JSON.stringify(app.logs));
}

// Debounce simples para persistência de logs
const debounceSaveLogs = (function() {
    let t;
    return function() {
        clearTimeout(t);
        t = setTimeout(saveLogs, 300);
    };
})();

function loadLogs() {
    const saved = localStorage.getItem('git-automatico-logs');
    if (saved) {
        app.logs = JSON.parse(saved);
    }
}

// Limpeza de dados
function clearData() {
    if (confirm('Deseja realmente limpar todos os dados salvos?\n\nIsso incluirá:\n- Credenciais\n- Logs\n- Configurações')) {
        localStorage.removeItem('git-automatico-credentials');
        localStorage.removeItem('git-automatico-logs');
        
        app.credentials = null;
        app.logs = [];
        
        updateConnectionStatus();
        showNotification('Dados limpos com sucesso!', 'success');
        addLog('info', 'Dados do sistema limpos');
        
        // Limpar formulários
        document.getElementById('github-token').value = '';
        document.getElementById('github-username').value = '';
    }
}

// Sistema de notificações
function showNotification(message, type = 'info') {
    const notification = document.getElementById('notification');
    const notificationText = notification.querySelector('.notification-text');
    
    notificationText.innerHTML = message;
    notification.className = `notification ${type}`;
    notification.style.display = 'block';

    // Anunciar via ARIA
    notification.setAttribute('aria-live', type === 'error' ? 'assertive' : 'polite');

    // Auto-esconder após 5 segundos
    clearTimeout(showNotification._timeout);
    showNotification._timeout = setTimeout(() => {
        hideNotification();
    }, 5000);
}

function hideNotification() {
    const notification = document.getElementById('notification');
    notification.style.display = 'none';
}

// Busca global
function openGlobalSearch() {
    const panel = document.getElementById('global-search');
    const input = document.getElementById('global-search-input');
    if (!panel || !input) return;
    panel.style.display = 'block';
    requestAnimationFrame(() => input.focus());
}

function closeGlobalSearch() {
    const panel = document.getElementById('global-search');
    const input = document.getElementById('global-search-input');
    const results = document.getElementById('search-results');
    if (panel) panel.style.display = 'none';
    if (input) input.value = '';
    if (results) results.innerHTML = '';
}

// Modais genéricos
function closeModal(id) {
    const modal = document.getElementById(id);
    if (modal) modal.style.display = 'none';
}

function showNotificationCenter() {
    const modal = document.getElementById('notification-center-modal');
    if (modal) modal.style.display = 'block';
}

function clearAllNotifications() {
    const list = document.getElementById('notifications-list');
    const badge = document.getElementById('notification-badge');
    if (list) list.innerHTML = '';
    if (badge) {
        badge.textContent = '0';
        badge.style.display = 'none';
    }
    addLog('info', 'Notificações limpas');
}

function showKeyboardShortcuts() {
    const modal = document.getElementById('shortcuts-modal');
    if (modal) modal.style.display = 'block';
}

function showBulkActions() {
    const modal = document.getElementById('bulk-actions-modal');
    if (modal) modal.style.display = 'block';
}

// Modo offline (simulado)
function toggleOfflineMode() {
    const offlineItem = document.getElementById('offline-status');
    const connectionItem = document.getElementById('connection-status');
    const btn = document.getElementById('offline-toggle');
    const active = offlineItem && offlineItem.style.display !== 'none';
    if (!active) {
        if (offlineItem) offlineItem.style.display = 'flex';
        if (connectionItem) {
            const span = connectionItem.querySelector('span');
            if (span) span.textContent = 'Sem conexão (simulado)';
            connectionItem.classList.remove('online');
            connectionItem.classList.add('offline');
        }
        if (btn) btn.setAttribute('aria-pressed', 'true');
        showNotification('Modo offline ativado (simulado)', 'info');
        addLog('info', 'Modo offline ativado');
    } else {
        if (offlineItem) offlineItem.style.display = 'none';
        if (btn) btn.setAttribute('aria-pressed', 'false');
        if (typeof updateConnectionStatus === 'function') updateConnectionStatus();
        showNotification('Modo offline desativado', 'success');
        addLog('info', 'Modo offline desativado');
    }
}

// Gerenciamento de Repositórios
async function loadRepositories() {
    if (!app.credentials) {
        showNotification('Configure as credenciais primeiro', 'warning');
        showSection('config-section');
        return;
    }

    // Mostrar skeleton loading
    showRepositorySkeleton();
    
    // Ocultar estatísticas durante o carregamento
    const stats = document.getElementById('repos-stats');
    stats.style.display = 'none';

    try {
        const response = await fetch('https://api.github.com/user/repos?per_page=100&sort=updated', {
            headers: {
                'Authorization': `token ${app.credentials.token}`,
                'Accept': 'application/vnd.github.v3+json'
            }
        });

        if (!response.ok) {
            throw new Error('Erro ao carregar repositórios');
        }

        app.repositories = await response.json();
        
        // Pequeno delay para mostrar o skeleton
        setTimeout(() => {
            displayRepositories(app.repositories);
            updateRepositoriesStats();
            addLog('info', `${app.repositories.length} repositórios carregados`);
        }, 500);

    } catch (error) {
        const container = document.getElementById('repos-container');
        container.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">❌</div>
                <div class="empty-state-title">Erro ao carregar repositórios</div>
                <div class="empty-state-description">
                    ${error.message}
                </div>
            </div>
        `;
        addLog('error', `Erro ao carregar repositórios: ${error.message}`);
    }
}

function displayRepositories(repos) {
    const container = document.getElementById('repos-container');
    if (!container) return;
    const searchInput = document.getElementById('repo-search');
    const searchQuery = (searchInput && searchInput.value ? searchInput.value : '').toLowerCase();
    const downloadBtn = document.getElementById('download-selected-btn');
    
    // Resetar seleção e botão de download (compatibilidade)
    app.credentials = app.credentials || {};
    app.credentials.repository = null;
    if (downloadBtn) {
        downloadBtn.disabled = true;
        downloadBtn.setAttribute('aria-disabled', 'true');
    }

    if (!Array.isArray(repos) || repos.length === 0) {
        container.innerHTML = `
            <div class="empty-state" role="status" aria-live="polite">
                <div class="empty-state-icon">📁</div>
                <div class="empty-state-title">Nenhum repositório encontrado</div>
                <div class="empty-state-description">
                    Tente ajustar os filtros de busca ou criar um novo repositório
                </div>
            </div>
        `;
        return;
    }

    const fragment = document.createDocumentFragment();

    repos.forEach((repo, index) => {
        const badges = getRepositoryBadges(repo);
        const languageIndicator = repo.language ? getLanguageIndicator(repo.language) : '';
        const defaultBranch = (repo.default_branch || app.settings.defaultBranch || 'main');
        const zipUrl = `https://github.com/${repo.owner.login}/${repo.name}/archive/refs/heads/${encodeURIComponent(defaultBranch)}.zip`;

        const wrapper = document.createElement('div');
        wrapper.className = `repo-item ${repo.private ? 'private' : ''}`;
        wrapper.setAttribute('role', 'listitem');
        wrapper.setAttribute('data-repo', repo.name);
        wrapper.style.animationDelay = `${index * 0.1}s`;
        wrapper.tabIndex = 0; // acessível
        wrapper.addEventListener('click', () => selectRepositoryForDownload(repo.name));
        wrapper.addEventListener('keyup', (e) => {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                selectRepositoryForDownload(repo.name);
            }
        });

        wrapper.innerHTML = `
            ${badges.length > 0 ? `<div class="repo-badges">${badges.join('')}</div>` : ''}
            <div class="repo-header">
                <a href="${repo.html_url}" target="_blank" class="repo-name" rel="noopener noreferrer">
                    <i class="fas fa-${repo.private ? 'lock' : 'book'}" aria-hidden="true"></i>
                    ${highlightSearchTerm(repo.name, searchQuery)}
                </a>
                <span class="repo-privacy ${repo.private ? 'private' : 'public'}" aria-label="${repo.private ? 'Repositório privado' : 'Repositório público'}">
                    ${repo.private ? 'Privado' : 'Público'}
                </span>
            </div>
            ${repo.description ? `<div class="repo-description">${highlightSearchTerm(repo.description, searchQuery)}</div>` : ''}
            <div class="repo-meta">
                ${repo.language ? `<div class="repo-meta-item repo-tooltip" data-tooltip="Linguagem principal">
                    ${languageIndicator}
                    ${highlightSearchTerm(repo.language, searchQuery)}
                </div>` : ''}
                <div class="repo-meta-item repo-tooltip" data-tooltip="Estrelas">
                    <i class="fas fa-star" aria-hidden="true"></i>
                    ${formatNumber(repo.stargazers_count)}
                </div>
                <div class="repo-meta-item repo-tooltip" data-tooltip="Forks">
                    <i class="fas fa-code-branch" aria-hidden="true"></i>
                    ${formatNumber(repo.forks_count)}
                </div>
                <div class="repo-meta-item repo-tooltip" data-tooltip="Última atualização">
                    <i class="fas fa-clock" aria-hidden="true"></i>
                    ${formatDate(repo.updated_at)}
                </div>
                ${repo.size ? `<div class="repo-meta-item repo-tooltip" data-tooltip="Tamanho do repositório">
                    <i class="fas fa-hdd" aria-hidden="true"></i>
                    ${formatSize(repo.size)}
                </div>` : ''}
                <div class="repo-meta-item repo-tooltip" data-tooltip="Branch padrão">
                    <i class="fas fa-code-branch" aria-hidden="true"></i>
                    ${defaultBranch}
                </div>
            </div>
            <div class="repo-actions">
                <a href="${repo.html_url}" target="_blank" class="btn small github" rel="noopener noreferrer">
                    <i class="fab fa-github" aria-hidden="true"></i>
                    Ver no GitHub
                </a>
                <button class="btn small clone" onclick="cloneRepository('${repo.clone_url}')" aria-label="Copiar URL de clone para ${repo.name}">
                    <i class="fas fa-download" aria-hidden="true"></i>
                    Clone URL
                </button>
                ${repo.has_pages ? `<a href="https://${app.credentials.username}.github.io/${repo.name}" target="_blank" class="btn small pages" rel="noopener noreferrer">
                    <i class="fas fa-globe" aria-hidden="true"></i>
                    GitHub Pages
                </a>` : ''}
                <a class="btn small primary" href="${zipUrl}" target="_blank" rel="noopener noreferrer" aria-label="Baixar ${repo.name} (.zip)">
                    <i class="fas fa-file-zipper" aria-hidden="true"></i>
                    Baixar .zip
                </a>
            </div>
        `;
        fragment.appendChild(wrapper);
    });

    container.innerHTML = '';
    container.appendChild(fragment);

    // Adicionar classe para animações e atributos ARIA
    requestAnimationFrame(() => {
        container.classList.add('loaded');
        container.setAttribute('role', 'list');
        container.setAttribute('aria-live', 'polite');
    });
}

function getRepositoryBadges(repo) {
    const badges = [];
    
    if (repo.archived) {
        badges.push('<span class="repo-badge archived">Arquivado</span>');
    }
    
    if (repo.fork) {
        badges.push('<span class="repo-badge fork">Fork</span>');
    }
    
    if (repo.is_template) {
        badges.push('<span class="repo-badge template">Template</span>');
    }
    
    if (repo.stargazers_count > 10) {
        badges.push('<span class="repo-badge featured">Destaque</span>');
    }
    
    return badges;
}

function getLanguageIndicator(language) {
    const languageClass = language.toLowerCase().replace(/[^a-z]/g, '');
    return `<span class="language-indicator">
        <span class="language-dot ${languageClass}"></span>
    </span>`;
}

function formatNumber(num) {
    if (num >= 1000000) {
        return (num / 1000000).toFixed(1) + 'M';
    } else if (num >= 1000) {
        return (num / 1000).toFixed(1) + 'K';
    }
    return num.toString();
}

function formatSize(sizeKB) {
    if (sizeKB >= 1024 * 1024) {
        return (sizeKB / (1024 * 1024)).toFixed(1) + ' GB';
    } else if (sizeKB >= 1024) {
        return (sizeKB / 1024).toFixed(1) + ' MB';
    }
    return sizeKB + ' KB';
}

function showRepositorySkeleton() {
    const container = document.getElementById('repos-container');
    const skeletonCount = 6;
    
    container.innerHTML = Array(skeletonCount).fill().map(() => `
        <div class="repo-skeleton">
            <div class="skeleton-line short"></div>
            <div class="skeleton-line medium"></div>
            <div class="skeleton-line long"></div>
            <div class="skeleton-line medium"></div>
        </div>
    `).join('');
}

function updateRepositoriesStats(list = null) {
    const stats = document.getElementById('repos-stats');
    stats.style.display = 'grid';
    
    const source = Array.isArray(list) ? list : app.repositories;
    const totalRepos = source.length;
    const publicRepos = source.filter(repo => !repo.private).length;
    const privateRepos = source.filter(repo => repo.private).length;
    const totalStars = source.reduce((sum, repo) => sum + repo.stargazers_count, 0);
    
    document.getElementById('total-repos').textContent = totalRepos;
    document.getElementById('public-repos').textContent = publicRepos;
    document.getElementById('private-repos').textContent = privateRepos;
    document.getElementById('total-stars').textContent = totalStars;
}

// Debounce para busca em tempo real
let searchTimeout;

function searchRepositories() {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
        performSearch();
    }, 250); // resposta um pouco mais ágil
}

function performSearch() {
    const query = document.getElementById('repo-search').value.toLowerCase();
    const filter = document.getElementById('repo-filter').value;
    const sort = document.getElementById('repo-sort').value;
    
    // Mostrar indicador de busca
    const container = document.getElementById('repos-container');
    if (query.length > 0) {
        container.classList.add('searching');
    } else {
        container.classList.remove('searching');
    }
    
    let filteredRepos = app.repositories.filter(repo => {
        const matchesSearch = repo.name.toLowerCase().includes(query) || 
                            (repo.description && repo.description.toLowerCase().includes(query)) ||
                            (repo.language && repo.language.toLowerCase().includes(query));
        
        switch (filter) {
            case 'public':
                return matchesSearch && !repo.private;
            case 'private':
                return matchesSearch && repo.private;
            case 'owner':
                return matchesSearch && repo.owner.login === app.credentials.username;
            default:
                return matchesSearch;
        }
    });
    
    // Ordenar
    filteredRepos.sort((a, b) => {
        switch (sort) {
            case 'name':
                return a.name.localeCompare(b.name);
            case 'created':
                return new Date(b.created_at) - new Date(a.created_at);
            case 'stars':
                return b.stargazers_count - a.stargazers_count;
            default: // updated
                return new Date(b.updated_at) - new Date(a.updated_at);
        }
    });
    
    // Atualizar contador de resultados
    updateSearchResults(filteredRepos.length, app.repositories.length, query, filter);
    
    displayRepositories(filteredRepos);
    updateRepositoriesStats(filteredRepos);
    
    // Log apenas se for uma busca manual (não em tempo real)
    if (query.length > 2 || filter !== 'all' || sort !== 'updated') {
        addLog('info', `Busca realizada: ${filteredRepos.length} repositórios encontrados`);
    }
}

function updateSearchResults(filtered, total, query, filter) {
    // Remover contador anterior se existir
    const existingCounter = document.querySelector('.search-results-counter');
    if (existingCounter) {
        existingCounter.remove();
    }
    
    // Criar novo contador apenas se houver filtros ativos
    if (query.length > 0 || filter !== 'all') {
        const counter = document.createElement('div');
        counter.className = 'search-results-counter';
        
        let filterText = '';
        if (filter !== 'all') {
            const filterLabels = {
                'public': 'públicos',
                'private': 'privados',
                'owner': 'próprios'
            };
            filterText = ` (${filterLabels[filter]})`;
        }
        
        counter.innerHTML = `
            <span class="results-count">${filtered}</span> de 
            <span class="total-count">${total}</span> repositórios${filterText}
            ${query ? ` para "<strong>${query}</strong>"` : ''}
        `;
        
        const reposSection = document.querySelector('.repos-stats');
        reposSection.parentNode.insertBefore(counter, reposSection.nextSibling);
    }
}

function clearSearch() {
    document.getElementById('repo-search').value = '';
    document.getElementById('repo-filter').value = 'all';
    document.getElementById('repo-sort').value = 'updated';
    
    const container = document.getElementById('repos-container');
    container.classList.remove('searching');
    
    // Remover contador de resultados
    const existingCounter = document.querySelector('.search-results-counter');
    if (existingCounter) {
        existingCounter.remove();
    }
    
    displayRepositories(app.repositories);
    // atualizar estatísticas com a lista completa
    updateRepositoriesStats();
    addLog('info', 'Filtros limpos');
}

function cloneRepository(cloneUrl) {
    navigator.clipboard.writeText(cloneUrl).then(() => {
        showNotification('URL de clone copiada para área de transferência!', 'success');
    }).catch(() => {
        prompt('URL de clone:', cloneUrl);
    });
}

// Seleção e download no "Meus Repositórios"
function selectRepositoryForDownload(repoName) {
    // Remover destaque anterior
    document.querySelectorAll('.repo-item.selected').forEach(el => el.classList.remove('selected'));
    // Destacar o selecionado
    const el = document.querySelector(`.repo-item[data-repo="${CSS.escape(repoName)}"]`);
    if (el) el.classList.add('selected');

    // Salvar no estado para reuso pelo download
    app.credentials = app.credentials || {};
    app.credentials.repository = repoName;

    // Habilitar botão de download
    const downloadBtn = document.getElementById('download-selected-btn');
    if (downloadBtn) {
        downloadBtn.disabled = false;
        downloadBtn.setAttribute('aria-disabled', 'false');
    }

    showNotification(`Selecionado: ${repoName}. Clique em "Baixar Repositório Selecionado".`, 'info');
    addLog('info', `Repositório selecionado para download: ${repoName}`);
}

function downloadSelectedRepository() {
    // Reaproveita a lógica existente de downloadRepository, mas sem depender do botão do header
    const fakeEvent = { preventDefault: function() {}, target: document.body };
    downloadRepository(fakeEvent);
}

// Dashboard
async function loadDashboard() {
    if (!app.credentials) {
        showNotification('Configure as credenciais primeiro', 'warning');
        showSection('config-section');
        return;
    }

    try {
        await Promise.all([
            loadUserInfo(),
            loadRecentActivity(),
            loadLanguagesStats(),
            loadStarredRepos()
        ]);
        
        // Atualizar métricas do header do dashboard aprimorado
        await updateDashboardMetrics();
        
        // Carregar tab ativa (padrão: overview)
        const activeTab = document.querySelector('.tab-btn.active');
        if (activeTab) {
            const tabName = activeTab.getAttribute('onclick').match(/'([^']+)'/)[1];
            await loadTabContent(tabName);
        } else {
            // Ativar primeira tab por padrão se existir
            const firstTab = document.querySelector('.tab-btn');
            if (firstTab) {
                firstTab.click();
            }
        }
        
        addLog('info', 'Dashboard carregado com sucesso');
    } catch (error) {
        addLog('error', `Erro ao carregar dashboard: ${error.message}`);
    }
}

async function loadTabContent(tabName) {
    switch(tabName) {
        case 'overview':
            await loadOverviewTab();
            break;
        case 'activity':
            await loadActivityTab();
            break;
        case 'languages':
            await loadLanguagesTab();
            break;
        case 'repositories':
            await loadRepositoriesTab();
            break;
    }
}

async function loadUserInfo() {
    try {
        const response = await fetch('https://api.github.com/user', {
            headers: {
                'Authorization': `token ${app.credentials.token}`,
                'Accept': 'application/vnd.github.v3+json'
            }
        });

        if (response.ok) {
            app.userInfo = await response.json();
            displayUserStats();
        }
    } catch (error) {
        console.error('Erro ao carregar info do usuário:', error);
    }
}

async function loadRecentActivity() {
    const container = document.getElementById('recent-activity');
    
    try {
        const response = await fetch(`https://api.github.com/users/${app.credentials.username}/events?per_page=10`, {
            headers: {
                'Authorization': `token ${app.credentials.token}`,
                'Accept': 'application/vnd.github.v3+json'
            }
        });

        if (response.ok) {
            const events = await response.json();
            displayRecentActivity(events);
        }
    } catch (error) {
        container.innerHTML = '<div class="loading-message">❌ Erro ao carregar atividades</div>';
    }
}

function displayRecentActivity(events) {
    const container = document.getElementById('recent-activity');
    
    if (events.length === 0) {
        container.innerHTML = '<div class="loading-message">📭 Nenhuma atividade recente</div>';
        return;
    }

    container.innerHTML = events.slice(0, 5).map(event => {
        const icon = getEventIcon(event.type);
        const description = getEventDescription(event);
        
        return `
            <div class="activity-item">
                <div class="activity-icon">
                    <i class="${icon}"></i>
                </div>
                <div class="activity-content">
                    <div class="activity-title">${description}</div>
                    <div class="activity-time">${formatDate(event.created_at)}</div>
                </div>
            </div>
        `;
    }).join('');
}

async function loadLanguagesStats() {
    // Mantida por compatibilidade; agora usamos containers específicos nas tabs
    return Promise.resolve();
}

function displayLanguagesChart(languages) {
    // Não utilizado mais diretamente; distribuição é mostrada nas tabs específicas
}

async function loadStarredRepos() {
    const container = document.getElementById('starred-repos');
    
    try {
        const response = await fetch('https://api.github.com/user/starred?per_page=5', {
            headers: {
                'Authorization': `token ${app.credentials.token}`,
                'Accept': 'application/vnd.github.v3+json'
            }
        });

        if (response.ok) {
            const starred = await response.json();
            displayStarredRepos(starred);
        }
    } catch (error) {
        container.innerHTML = '<div class="loading-message">❌ Erro ao carregar favoritos</div>';
    }
}

function displayStarredRepos(repos) {
    const container = document.getElementById('starred-repos');
    
    if (repos.length === 0) {
        container.innerHTML = '<div class="loading-message">⭐ Nenhum repositório favoritado</div>';
        return;
    }
    
    container.innerHTML = repos.map(repo => `
        <div class="starred-repo">
            <a href="${repo.html_url}" target="_blank">${repo.name}</a>
            <span class="stars">
                <i class="fas fa-star"></i>
                ${repo.stargazers_count}
            </span>
        </div>
    `).join('');
}

function displayUserStats() {
    const container = document.getElementById('user-stats');
    
    if (!app.userInfo) {
        container.innerHTML = '<div class="loading-message">❌ Erro ao carregar estatísticas</div>';
        return;
    }
    
    container.innerHTML = `
        <div class="stats-grid">
            <div class="stat-box">
                <span class="number">${app.userInfo.public_repos}</span>
                <span class="label">Repositórios</span>
            </div>
            <div class="stat-box">
                <span class="number">${app.userInfo.followers}</span>
                <span class="label">Seguidores</span>
            </div>
            <div class="stat-box">
                <span class="number">${app.userInfo.following}</span>
                <span class="label">Seguindo</span>
            </div>
            <div class="stat-box">
                <span class="number">${app.userInfo.public_gists}</span>
                <span class="label">Gists</span>
            </div>
        </div>
    `;
}

function refreshDashboard() {
    app.dashboardData = null;
    loadDashboard();
}

// Novas funcionalidades do Dashboard Aprimorado
function showDashboardTab(tabName, el) {
    // Remove active class from all tabs and content
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    
    // Add active class to selected tab and content
    if (el) el.classList.add('active');
    const tab = document.getElementById(`${tabName}-tab`);
    if (tab) tab.classList.add('active');
    
    // Load specific tab content
    switch(tabName) {
        case 'overview':
            loadOverviewTab();
            break;
        case 'activity':
            loadActivityTab();
            break;
        case 'languages':
            loadLanguagesTab();
            break;
        case 'repositories':
            loadRepositoriesTab();
            break;
    }
}

async function loadOverviewTab() {
    await Promise.all([
        loadContributionChart(),
        loadAchievements(),
        loadProductivityStats()
    ]);
}

async function loadActivityTab() {
    await Promise.all([
        loadActivityCalendar(),
        loadRecentActivity()
    ]);
}

async function loadLanguagesTab() {
    await Promise.all([
        loadLanguagesPieChart(),
        loadLanguagesTrend(),
        loadDetailedLanguagesStats()
    ]);
}

async function loadRepositoriesTab() {
    await Promise.all([
        loadStarredRepos(),
        loadRepositoryPerformance(),
        loadRepositoryTimeline()
    ]);
}

// Métricas do Header
async function updateDashboardMetrics() {
    if (!app.credentials) return;
    
    try {
        // Carregar dados do usuário se não existirem
        if (!app.userInfo) {
            await loadUserInfo();
        }
        
        // Calcular métricas
        const metrics = await calculateMetrics();
        
        // Atualizar elementos
        document.getElementById('total-commits').textContent = metrics.commits;
        document.getElementById('streak-days').textContent = metrics.streak;
        document.getElementById('total-stars-metric').textContent = metrics.stars;
        document.getElementById('total-followers').textContent = metrics.followers;
        
        // Atualizar mudanças (simulado)
        updateMetricChanges(metrics);
        
    } catch (error) {
        console.error('Erro ao atualizar métricas:', error);
    }
}

async function calculateMetrics() {
    const metrics = {
        commits: 0,
        streak: 0,
        stars: 0,
        followers: app.userInfo?.followers || 0
    };
    
    // Calcular total de stars dos repositórios
    if (app.repositories.length > 0) {
        metrics.stars = app.repositories.reduce((total, repo) => total + repo.stargazers_count, 0);
    }
    
    // Simular commits e streak (em uma implementação real, seria calculado dos eventos)
    metrics.commits = Math.floor(Math.random() * 1000) + 500;
    metrics.streak = Math.floor(Math.random() * 30) + 1;
    
    return metrics;
}

function updateMetricChanges(metrics) {
    // Simular mudanças percentuais
    const changes = {
        commits: Math.floor(Math.random() * 20) - 10,
        streak: Math.floor(Math.random() * 5) - 2,
        stars: Math.floor(Math.random() * 10) - 5,
        followers: Math.floor(Math.random() * 5) - 2
    };
    
    updateMetricChange('commits-change', changes.commits, '%');
    updateMetricChange('streak-change', changes.streak, '');
    updateMetricChange('stars-change', changes.stars, '');
    updateMetricChange('followers-change', changes.followers, '');
}

function updateMetricChange(elementId, value, suffix) {
    const element = document.getElementById(elementId);
    const sign = value >= 0 ? '+' : '';
    element.textContent = `${sign}${value}${suffix}`;
    element.className = `metric-change ${value >= 0 ? 'positive' : 'negative'}`;
}

// Gráfico de Contribuições
async function loadContributionChart() {
    const container = document.getElementById('contribution-chart');
    const period = document.getElementById('contribution-period').value;
    
    try {
        // Simular dados de contribuição
        const data = generateContributionData(period);
        displayContributionChart(data);
    } catch (error) {
        container.innerHTML = '<div class="loading-message">❌ Erro ao carregar gráfico</div>';
    }
}

function generateContributionData(period) {
    const data = [];
    const days = period === 'week' ? 7 : period === 'month' ? 30 : period === 'quarter' ? 90 : 365;
    
    for (let i = 0; i < days; i++) {
        const date = new Date();
        date.setDate(date.getDate() - i);
        data.push({
            date: date.toISOString().split('T')[0],
            contributions: Math.floor(Math.random() * 10)
        });
    }
    
    return data.reverse();
}

function displayContributionChart(data) {
    const container = document.getElementById('contribution-chart');
    const maxContributions = Math.max(...data.map(d => d.contributions));
    
    container.innerHTML = `
        <div class="contribution-grid">
            ${data.map(day => `
                <div class="contribution-day" 
                     style="opacity: ${day.contributions / maxContributions || 0.1}"
                     title="${day.date}: ${day.contributions} contribuições">
                </div>
            `).join('')}
        </div>
        <div class="contribution-legend">
            <span>Menos</span>
            <div class="legend-scale">
                <div class="legend-day" style="opacity: 0.1"></div>
                <div class="legend-day" style="opacity: 0.3"></div>
                <div class="legend-day" style="opacity: 0.6"></div>
                <div class="legend-day" style="opacity: 1"></div>
            </div>
            <span>Mais</span>
        </div>
    `;
}

function updateContributionChart() {
    loadContributionChart();
}

// Conquistas
async function loadAchievements() {
    const container = document.getElementById('achievements-list');
    
    try {
        const achievements = generateAchievements();
        displayAchievements(achievements);
    } catch (error) {
        container.innerHTML = '<div class="loading-message">❌ Erro ao carregar conquistas</div>';
    }
}

function generateAchievements() {
    const allAchievements = [
        { icon: '🏆', title: 'Primeiro Repositório', description: 'Criou seu primeiro repositório' },
        { icon: '⭐', title: 'Primeira Star', description: 'Recebeu sua primeira star' },
        { icon: '🔥', title: 'Sequência de 7 dias', description: 'Commitou por 7 dias consecutivos' },
        { icon: '📚', title: 'Poliglota', description: 'Usou mais de 5 linguagens' },
        { icon: '🚀', title: 'Produtivo', description: 'Mais de 100 commits este mês' },
        { icon: '👥', title: 'Colaborativo', description: 'Contribuiu para projetos de outros' }
    ];
    
    // Retornar algumas conquistas aleatórias
    return allAchievements.slice(0, 4);
}

function displayAchievements(achievements) {
    const container = document.getElementById('achievements-list');
    
    container.innerHTML = achievements.map(achievement => `
        <div class="achievement-item">
            <div class="achievement-icon">${achievement.icon}</div>
            <div class="achievement-content">
                <h4>${achievement.title}</h4>
                <p>${achievement.description}</p>
            </div>
        </div>
    `).join('');
}

// Estatísticas de Produtividade
async function loadProductivityStats() {
    const container = document.getElementById('productivity-stats');
    
    try {
        const stats = calculateProductivityStats();
        displayProductivityStats(stats);
    } catch (error) {
        container.innerHTML = '<div class="loading-message">❌ Erro ao carregar estatísticas</div>';
    }
}

function calculateProductivityStats() {
    return {
        'Commits esta semana': Math.floor(Math.random() * 50) + 10,
        'Repositórios ativos': Math.floor(Math.random() * 10) + 3,
        'Linguagens usadas': Math.floor(Math.random() * 8) + 2,
        'Issues fechadas': Math.floor(Math.random() * 20) + 5,
        'Pull Requests': Math.floor(Math.random() * 15) + 2
    };
}

function displayProductivityStats(stats) {
    const container = document.getElementById('productivity-stats');
    
    container.innerHTML = Object.entries(stats).map(([label, value]) => `
        <div class="productivity-item">
            <span class="productivity-label">${label}</span>
            <span class="productivity-value">${value}</span>
        </div>
    `).join('');
}

// Calendário de Atividades
async function loadActivityCalendar() {
    const container = document.getElementById('activity-calendar');
    
    try {
        const calendarData = generateCalendarData();
        displayActivityCalendar(calendarData);
    } catch (error) {
        container.innerHTML = '<div class="loading-message">❌ Erro ao carregar calendário</div>';
    }
}

function generateCalendarData() {
    const data = [];
    const today = new Date();
    
    // Gerar dados para os últimos 365 dias
    for (let i = 0; i < 365; i++) {
        const date = new Date(today);
        date.setDate(date.getDate() - i);
        data.push({
            date: date.toISOString().split('T')[0],
            activity: Math.floor(Math.random() * 5)
        });
    }
    
    return data.reverse();
}

function displayActivityCalendar(data) {
    const container = document.getElementById('activity-calendar');
    
    container.innerHTML = `
        <div class="calendar-header">
            <h4>Últimos 12 meses</h4>
        </div>
        <div class="calendar-grid">
            ${data.map(day => `
                <div class="calendar-day activity-level-${day.activity}" 
                     title="${day.date}: ${day.activity} atividades">
                </div>
            `).join('')}
        </div>
    `;
}

// Gráfico de Pizza das Linguagens
async function loadLanguagesPieChart() {
    const container = document.getElementById('languages-pie-chart');
    
    try {
        if (app.repositories.length === 0) {
            await loadRepositories();
        }
        
        const languages = calculateLanguageDistribution();
        displayLanguagesPieChart(languages);
    } catch (error) {
        container.innerHTML = '<div class="loading-message">❌ Erro ao carregar gráfico</div>';
    }
}

function calculateLanguageDistribution() {
    const languages = {};
    
    app.repositories.forEach(repo => {
        if (repo.language) {
            languages[repo.language] = (languages[repo.language] || 0) + 1;
        }
    });
    
    return languages;
}

function displayLanguagesPieChart(languages) {
    const container = document.getElementById('languages-pie-chart');
    const total = Object.values(languages).reduce((sum, count) => sum + count, 0);
    
    if (total === 0) {
        container.innerHTML = '<div class="loading-message">📊 Nenhuma linguagem detectada</div>';
        return;
    }
    
    const sortedLanguages = Object.entries(languages)
        .sort(([,a], [,b]) => b - a)
        .slice(0, 6);
    
    const colors = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c'];
    
    container.innerHTML = `
        <div class="pie-chart-container">
            <div class="pie-chart">
                ${sortedLanguages.map(([lang, count], index) => {
                    const percentage = (count / total) * 100;
                    return `<div class="pie-slice" style="--percentage: ${percentage}%; --color: ${colors[index]}"></div>`;
                }).join('')}
            </div>
            <div class="pie-legend">
                ${sortedLanguages.map(([lang, count], index) => {
                    const percentage = ((count / total) * 100).toFixed(1);
                    return `
                        <div class="legend-item">
                            <div class="legend-color" style="background: ${colors[index]}"></div>
                            <span>${lang} (${percentage}%)</span>
                        </div>
                    `;
                }).join('')}
            </div>
        </div>
    `;
}

// Tendências de Linguagens
async function loadLanguagesTrend() {
    const container = document.getElementById('languages-trend');
    
    try {
        const trendData = generateLanguagesTrendData();
        displayLanguagesTrend(trendData);
    } catch (error) {
        container.innerHTML = '<div class="loading-message">❌ Erro ao carregar tendências</div>';
    }
}

function generateLanguagesTrendData() {
    const languages = ['JavaScript', 'Python', 'Java', 'TypeScript', 'C++'];
    const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'];
    
    return languages.map(lang => ({
        name: lang,
        data: months.map(() => Math.floor(Math.random() * 100))
    }));
}

function displayLanguagesTrend(trendData) {
    const container = document.getElementById('languages-trend');
    
    container.innerHTML = `
        <div class="trend-chart">
            <div class="trend-legend">
                ${trendData.map((lang, index) => `
                    <div class="trend-legend-item">
                        <div class="trend-color" style="background: hsl(${index * 60}, 70%, 50%)"></div>
                        <span>${lang.name}</span>
                    </div>
                `).join('')}
            </div>
            <div class="trend-message">
                📈 Gráfico de tendências em desenvolvimento...
            </div>
        </div>
    `;
}

// Estatísticas Detalhadas de Linguagens
async function loadDetailedLanguagesStats() {
    const container = document.getElementById('languages-stats');
    
    try {
        const languages = calculateLanguageDistribution();
        displayDetailedLanguagesStats(languages);
    } catch (error) {
        container.innerHTML = '<div class="loading-message">❌ Erro ao carregar estatísticas</div>';
    }
}

function displayDetailedLanguagesStats(languages) {
    const container = document.getElementById('languages-stats');
    const total = Object.values(languages).reduce((sum, count) => sum + count, 0);
    
    if (total === 0) {
        container.innerHTML = '<div class="loading-message">📊 Nenhuma linguagem detectada</div>';
        return;
    }
    
    const sortedLanguages = Object.entries(languages)
        .sort(([,a], [,b]) => b - a);
    
    const colors = {
        'JavaScript': '#f7df1e',
        'Python': '#3776ab',
        'Java': '#ed8b00',
        'TypeScript': '#3178c6',
        'HTML': '#e34f26',
        'CSS': '#1572b6',
        'C++': '#00599c',
        'C#': '#239120',
        'PHP': '#777bb4',
        'Ruby': '#cc342d'
    };
    
    container.innerHTML = sortedLanguages.map(([lang, count]) => {
        const percentage = ((count / total) * 100).toFixed(1);
        const color = colors[lang] || '#667eea';
        
        return `
            <div class="language-item">
                <div class="language-color" style="background: ${color}"></div>
                <div class="language-info">
                    <div class="language-name">${lang}</div>
                    <div class="language-percentage">${count} repositórios (${percentage}%)</div>
                    <div class="language-bar">
                        <div class="language-bar-fill" style="width: ${percentage}%; background: ${color}"></div>
                    </div>
                </div>
            </div>
        `;
    }).join('');
}

// Performance dos Repositórios
async function loadRepositoryPerformance() {
    const container = document.getElementById('repo-performance');
    
    try {
        const performance = calculateRepositoryPerformance();
        displayRepositoryPerformance(performance);
    } catch (error) {
        container.innerHTML = '<div class="loading-message">❌ Erro ao carregar performance</div>';
    }
}

function calculateRepositoryPerformance() {
    if (app.repositories.length === 0) {
        return [];
    }
    
    return app.repositories
        .sort((a, b) => b.stargazers_count - a.stargazers_count)
        .slice(0, 5)
        .map(repo => ({
            name: repo.name,
            stars: repo.stargazers_count,
            forks: repo.forks_count,
            score: repo.stargazers_count + repo.forks_count * 2
        }));
}

function displayRepositoryPerformance(performance) {
    const container = document.getElementById('repo-performance');
    
    if (performance.length === 0) {
        container.innerHTML = '<div class="loading-message">📊 Nenhum repositório encontrado</div>';
        return;
    }
    
    const maxScore = Math.max(...performance.map(p => p.score));
    
    container.innerHTML = performance.map(repo => `
        <div class="performance-item">
            <div class="performance-name">${repo.name}</div>
            <div class="performance-stats">
                <span>⭐ ${repo.stars}</span>
                <span>🍴 ${repo.forks}</span>
            </div>
            <div class="performance-bar">
                <div class="performance-fill" style="width: ${(repo.score / maxScore) * 100}%"></div>
            </div>
        </div>
    `).join('');
}

// Timeline dos Repositórios
async function loadRepositoryTimeline() {
    const container = document.getElementById('repo-timeline');
    
    try {
        const timeline = createRepositoryTimeline();
        displayRepositoryTimeline(timeline);
    } catch (error) {
        container.innerHTML = '<div class="loading-message">❌ Erro ao carregar timeline</div>';
    }
}

function createRepositoryTimeline() {
    if (app.repositories.length === 0) {
        return [];
    }
    
    return app.repositories
        .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
        .slice(0, 10)
        .map(repo => ({
            name: repo.name,
            date: repo.created_at,
            description: repo.description || 'Sem descrição',
            language: repo.language
        }));
}

function displayRepositoryTimeline(timeline) {
    const container = document.getElementById('repo-timeline');
    
    if (timeline.length === 0) {
        container.innerHTML = '<div class="loading-message">📅 Nenhum repositório encontrado</div>';
        return;
    }
    
    container.innerHTML = timeline.map(repo => `
        <div class="timeline-item">
            <div class="timeline-date">${formatDate(repo.date)}</div>
            <div class="timeline-content">
                <h4>${repo.name}</h4>
                <p>${repo.description}</p>
                ${repo.language ? `<span class="timeline-language">${repo.language}</span>` : ''}
            </div>
        </div>
    `).join('');
}

// Exportar dados do dashboard
function exportDashboardData() {
    const data = {
        userInfo: app.userInfo,
        repositories: app.repositories,
        metrics: {
            totalRepos: app.repositories.length,
            totalStars: app.repositories.reduce((sum, repo) => sum + repo.stargazers_count, 0),
            languages: calculateLanguageDistribution()
        },
        exportDate: new Date().toISOString()
    };
    
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `github-dashboard-${new Date().toISOString().split('T')[0]}.json`;
    a.click();
    URL.revokeObjectURL(url);
    
    showNotification('Dados do dashboard exportados com sucesso!', 'success');
}

// Funções auxiliares
function formatDate(dateString) {
    const date = new Date(dateString);
    const now = new Date();
    const diffInHours = (now - date) / (1000 * 60 * 60);
    
    if (diffInHours < 24) {
        return `${Math.floor(diffInHours)}h atrás`;
    } else if (diffInHours < 24 * 7) {
        return `${Math.floor(diffInHours / 24)}d atrás`;
    } else {
        return date.toLocaleDateString('pt-BR');
    }
}

function getEventIcon(eventType) {
    const icons = {
        'PushEvent': 'fas fa-code-commit',
        'CreateEvent': 'fas fa-plus',
        'DeleteEvent': 'fas fa-trash',
        'ForkEvent': 'fas fa-code-branch',
        'StarEvent': 'fas fa-star',
        'WatchEvent': 'fas fa-eye',
        'IssuesEvent': 'fas fa-exclamation-circle',
        'PullRequestEvent': 'fas fa-code-branch',
        'ReleaseEvent': 'fas fa-tag'
    };
    
    return icons[eventType] || 'fas fa-circle';
}

function getEventDescription(event) {
    const repo = event.repo.name;
    
    switch (event.type) {
        case 'PushEvent':
            return `Push em ${repo}`;
        case 'CreateEvent':
            return `Criou ${event.payload.ref_type} em ${repo}`;
        case 'DeleteEvent':
            return `Deletou ${event.payload.ref_type} em ${repo}`;
        case 'ForkEvent':
            return `Fork de ${repo}`;
        case 'StarEvent':
            return `⭐ ${repo}`;
        case 'WatchEvent':
            return `👀 ${repo}`;
        case 'IssuesEvent':
            return `${event.payload.action} issue em ${repo}`;
        case 'PullRequestEvent':
            return `${event.payload.action} PR em ${repo}`;
        case 'ReleaseEvent':
            return `Release em ${repo}`;
        default:
            return `${event.type} em ${repo}`;
    }
}

// Templates
function selectTemplate(templateId, ev) {
    // Remover seleção anterior
    document.querySelectorAll('.template-card').forEach(card => {
        card.classList.remove('selected');
    });
    
    // Selecionar novo template (usar evento se disponível)
    const card = (ev && ev.currentTarget) ? ev.currentTarget : document.querySelector(`.template-card[onclick*="${templateId}"]`);
    if (card) card.classList.add('selected');
    app.selectedTemplate = templateId;
    
    // Mostrar preview
    showTemplatePreview(templateId);
    addLog('info', `Template selecionado: ${app.templates[templateId].name}`);
}

function showTemplatePreview(templateId) {
    const template = app.templates[templateId];
    const previewSection = document.getElementById('template-preview');
    const previewContent = document.getElementById('preview-content');
    
    previewSection.style.display = 'block';
    
    // Mostrar estrutura de arquivos
    const fileStructure = Object.keys(template.files).map(file => 
        `<div class="file-preview">${file}</div>`
    ).join('');
    
    previewContent.innerHTML = `
        <h4>Estrutura de Arquivos:</h4>
        ${fileStructure}
        <h4>Exemplo (${Object.keys(template.files)[0]}):</h4>
        <pre><code>${template.files[Object.keys(template.files)[0]].substring(0, 300)}...</code></pre>
    `;
}

function useTemplate() {
    if (!app.selectedTemplate) {
        showNotification('Selecione um template primeiro', 'warning');
        return;
    }
    
    const template = app.templates[app.selectedTemplate];
    
    // Converter template para arquivos
    const files = [];
    Object.entries(template.files).forEach(([path, content]) => {
        const file = new File([content], path.split('/').pop(), { type: 'text/plain' });
        // Adicionar propriedade customizada para o caminho
        Object.defineProperty(file, 'webkitRelativePath', {
            value: path,
            writable: false
        });
        files.push(file);
    });
    
    app.selectedFiles = files;
    
    // Ir para seção de upload
    showSection('upload-section');
    displaySelectedFiles();
    
    // Sugerir nome baseado no template
    const repoNameInput = document.getElementById('repo-name');
    repoNameInput.value = `meu-${app.selectedTemplate.replace('-', '-')}`;
    
    // Habilitar botão de upload
    document.getElementById('upload-btn').disabled = false;
    
    showNotification(`Template "${template.name}" carregado!`, 'success');
    addLog('success', `Template ${template.name} aplicado com ${files.length} arquivos`);
}

function previewTemplate() {
    if (!app.selectedTemplate) {
        showNotification('Selecione um template primeiro', 'warning');
        return;
    }
    
    const template = app.templates[app.selectedTemplate];
    const newWindow = window.open('', '_blank', 'width=800,height=600');
    
    // Se for um template web, mostrar preview funcional
    if (template.files['index.html']) {
        newWindow.document.write(template.files['index.html']);
        if (template.files['style.css']) {
            newWindow.document.head.innerHTML += `<style>${template.files['style.css']}</style>`;
        }
        if (template.files['script.js']) {
            newWindow.document.body.innerHTML += `<script>${template.files['script.js']}</script>`;
        }
    } else {
        // Preview em formato texto
        let content = '<pre style="font-family: monospace; padding: 20px;">';
        Object.entries(template.files).forEach(([path, fileContent]) => {
            content += `=== ${path} ===\n${fileContent}\n\n`;
        });
        content += '</pre>';
        newWindow.document.write(content);
    }
}

function createCustomTemplate() {
    const name = prompt('Nome do template personalizado:');
    if (!name) return;
    
    if (app.selectedFiles.length === 0) {
        showNotification('Selecione arquivos para criar o template', 'warning');
        return;
    }
    
    // Criar template baseado nos arquivos selecionados
    const customTemplate = {
        name: name,
        description: 'Template personalizado',
        files: {}
    };
    
    // Converter arquivos para template (limitado a arquivos de texto)
    Promise.all(app.selectedFiles.map(file => {
        return new Promise(resolve => {
            const reader = new FileReader();
            reader.onload = () => {
                const path = file.webkitRelativePath || file.name;
                customTemplate.files[path] = reader.result;
                resolve();
            };
            reader.readAsText(file);
        });
    })).then(() => {
        const templateId = `custom-${Date.now()}`;
        app.templates[templateId] = customTemplate;
        
        // Salvar templates personalizados
        const customTemplates = JSON.parse(localStorage.getItem('custom-templates') || '{}');
        customTemplates[templateId] = customTemplate;
        localStorage.setItem('custom-templates', JSON.stringify(customTemplates));
        
        showNotification(`Template "${name}" criado com sucesso!`, 'success');
        addLog('success', `Template personalizado criado: ${name}`);
    }).catch(error => {
        showNotification('Erro ao criar template: apenas arquivos de texto são suportados', 'error');
        addLog('error', `Erro ao criar template: ${error.message}`);
    });
}

// Configurações Avançadas
function saveAdvancedSettings() {
    // Coletar valores dos campos
    app.settings.autoGitignore = document.getElementById('auto-gitignore').checked;
    app.settings.autoReadme = document.getElementById('auto-readme').checked;
    app.settings.compressImages = document.getElementById('compress-images').checked;
    app.settings.maxFileSize = parseInt(document.getElementById('max-file-size').value);
    app.settings.defaultBranch = document.getElementById('default-branch').value;
    app.settings.autoCommitMessage = document.getElementById('auto-commit-message').checked;
    app.settings.commitPrefix = document.getElementById('commit-prefix').value;
    app.settings.scanSecrets = document.getElementById('scan-secrets').checked;
    app.settings.encryptCredentials = document.getElementById('encrypt-credentials').checked;
    app.settings.sessionTimeout = parseInt(document.getElementById('session-timeout').value);
    app.settings.theme = document.getElementById('theme').value;
    app.settings.language = document.getElementById('language').value;
    app.settings.animations = document.getElementById('animations').checked;
    
    // Salvar no localStorage
    localStorage.setItem('git-automatico-settings', JSON.stringify(app.settings));
    

    
    // Aplicar animações
    document.body.style.animation = app.settings.animations ? '' : 'none';
    
    showNotification('Configurações salvas com sucesso!', 'success');
    addLog('info', 'Configurações avançadas atualizadas');
}

function loadAdvancedSettings() {
    const saved = localStorage.getItem('git-automatico-settings');
    if (saved) {
        app.settings = { ...app.settings, ...JSON.parse(saved) };
        populateSettingsForm();
    }
}

function populateSettingsForm() {
    if (!document.getElementById('auto-gitignore')) return;
    document.getElementById('auto-gitignore').checked = app.settings.autoGitignore;
    document.getElementById('auto-readme').checked = app.settings.autoReadme;
    document.getElementById('compress-images').checked = app.settings.compressImages;
    document.getElementById('max-file-size').value = app.settings.maxFileSize;
    document.getElementById('default-branch').value = app.settings.defaultBranch;
    document.getElementById('auto-commit-message').checked = app.settings.autoCommitMessage;
    document.getElementById('commit-prefix').value = app.settings.commitPrefix;
    document.getElementById('scan-secrets').checked = app.settings.scanSecrets;
    document.getElementById('encrypt-credentials').checked = app.settings.encryptCredentials;
    document.getElementById('session-timeout').value = app.settings.sessionTimeout;
    document.getElementById('theme').value = app.settings.theme;
    document.getElementById('language').value = app.settings.language;
    document.getElementById('animations').checked = app.settings.animations;
}

function resetSettings() {
    if (confirm('Deseja realmente restaurar as configurações padrão?')) {
        localStorage.removeItem('git-automatico-settings');
        app.settings = {
            autoGitignore: true,
            autoReadme: true,
            compressImages: false,
            maxFileSize: 25,
            defaultBranch: 'main',
            autoCommitMessage: true,
            commitPrefix: '✨ ',
            scanSecrets: true,
            encryptCredentials: true,
            sessionTimeout: 60,
            theme: 'light',
            language: 'pt-BR',
            animations: true
        };
        populateSettingsForm();

        showNotification('Configurações restauradas!', 'success');
        addLog('info', 'Configurações resetadas para os padrões');
    }
}



// Backup e Sincronização
function createBackup() {
    const backupData = {
        version: '3.0',
        timestamp: new Date().toISOString(),
        credentials: app.credentials,
        settings: app.settings,
        logs: app.logs.slice(0, 50), // Últimos 50 logs
        customTemplates: JSON.parse(localStorage.getItem('custom-templates') || '{}')
    };
    
    const blob = new Blob([JSON.stringify(backupData, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    
    const a = document.createElement('a');
    a.href = url;
    a.download = `git-automatico-backup-${new Date().toISOString().split('T')[0]}.json`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    
    // Atualizar último backup
    localStorage.setItem('last-backup', new Date().toISOString());
    updateLastBackupDisplay();
    
    showNotification('Backup criado com sucesso!', 'success');
    addLog('info', 'Backup local criado');
}

function restoreBackup() {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json';
    
    input.onchange = function(e) {
        const file = e.target.files[0];
        if (!file) return;
        
        const reader = new FileReader();
        reader.onload = function(event) {
            try {
                const backupData = JSON.parse(event.target.result);
                
                if (backupData.version && backupData.timestamp) {
                    // Restaurar dados
                    if (backupData.credentials) app.credentials = backupData.credentials;
                    if (backupData.settings) app.settings = backupData.settings;
                    if (backupData.logs) app.logs = backupData.logs;
                    
                    // Salvar no localStorage
                    if (app.credentials) {
                        localStorage.setItem('git-automatico-credentials', JSON.stringify(app.credentials));
                    }
                    localStorage.setItem('git-automatico-settings', JSON.stringify(app.settings));
                    localStorage.setItem('git-automatico-logs', JSON.stringify(app.logs));
                    
                    if (backupData.customTemplates) {
                        localStorage.setItem('custom-templates', JSON.stringify(backupData.customTemplates));
                        Object.assign(app.templates, backupData.customTemplates);
                    }
                    
                    // Aplicar configurações
                    populateSettingsForm();

                    updateConnectionStatus();
                    
                    showNotification(`Backup restaurado! (${new Date(backupData.timestamp).toLocaleDateString()})`, 'success');
                    addLog('success', `Backup restaurado de ${backupData.timestamp}`);
                } else {
                    throw new Error('Formato de backup inválido');
                }
            } catch (error) {
                showNotification(`Erro ao restaurar backup: ${error.message}`, 'error');
                addLog('error', `Erro no restore: ${error.message}`);
            }
        };
        reader.readAsText(file);
    };
    
    input.click();
}

function updateLastBackupDisplay() {
    const lastBackup = localStorage.getItem('last-backup');
    const element = document.getElementById('last-backup');
    
    if (lastBackup) {
        const date = new Date(lastBackup);
        element.textContent = date.toLocaleDateString('pt-BR') + ' às ' + date.toLocaleTimeString('pt-BR');
    } else {
        element.textContent = 'Nunca';
    }
}

function setupAutoSync() {
    const enabled = document.getElementById('auto-sync').checked;
    const interval = parseInt(document.getElementById('sync-interval').value);
    
    app.settings.autoSync = enabled;
    app.settings.syncInterval = interval;
    
    // Implementar sincronização automática aqui
    // Por segurança, vamos apenas salvar a configuração
    localStorage.setItem('git-automatico-settings', JSON.stringify(app.settings));
    
    showNotification(
        enabled ? `Sincronização automática ativada (${interval} min)` : 'Sincronização automática desativada',
        'success'
    );
    addLog('info', `Auto-sync ${enabled ? 'ativado' : 'desativado'}`);
}

function syncNow() {
    showNotification('Sincronização manual não implementada por segurança', 'info');
    addLog('info', 'Tentativa de sincronização manual');
}

function loadVersionHistory() {
    const container = document.getElementById('version-history');
    if (!container) return;
    container.innerHTML = '<div class="loading-message"><i class="fas fa-spinner fa-spin"></i>Carregando...</div>';
    
    // Simular carregamento de versões
    setTimeout(() => {
        container.innerHTML = `
            <div class="version-item">
                <div class="version-info">
                    <strong>v3.0.0</strong>
                    <div class="version-date">Atual - ${new Date().toLocaleDateString('pt-BR')}</div>
                </div>
                <div class="version-actions">
                    <button class="btn small" disabled>Atual</button>
                </div>
            </div>
            <div class="version-item">
                <div class="version-info">
                    <strong>v2.1.0</strong>
                    <div class="version-date">2 dias atrás</div>
                </div>
                <div class="version-actions">
                    <button class="btn small" onclick="showNotification('Funcionalidade em desenvolvimento', 'info')">Ver</button>
                </div>
            </div>
        `;
    }, 800);
}

// Ajuda com abas
function showHelpTab(tabId, el) {
    // Remover classe active de todas as abas
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    
    // Ativar aba selecionada
    if (el) el.classList.add('active');
    const content = document.getElementById(tabId);
    if (content) content.classList.add('active');
}

// Melhorar inicialização
function initializeApp() {
    loadCredentials();
    loadLogs();
    loadAdvancedSettings();
    loadCustomTemplates();
    setupFileUpload();
    runSystemCheck();
    updateConnectionStatus();
    updateLastBackupDisplay();
    
    // Log de inicialização
    addLog('info', 'DEV ALEKSANDRO ALVES');
}

function loadCustomTemplates() {
    const customTemplates = JSON.parse(localStorage.getItem('custom-templates') || '{}');
    Object.assign(app.templates, customTemplates);
}

// Eventos de conectividade
window.addEventListener('online', () => {
    updateConnectionStatus();
    showNotification('Conexão restaurada', 'success');
    addLog('info', 'Conexão com internet restaurada');
});

window.addEventListener('offline', () => {
    updateConnectionStatus();
    showNotification('Conexão perdida', 'warning');
    addLog('warning', 'Conexão com internet perdida');
});

// Detectar mudança de tema do sistema
const prefersDark = window.matchMedia('(prefers-color-scheme: dark)');
function handleSystemThemeChange() {
    if (app.settings.theme === 'auto') {
        // Atualizar meta theme-color para melhor integração com o SO
        const themeMeta = document.querySelector('meta[name="theme-color"]');
        if (themeMeta) {
            const isDark = prefersDark.matches;
            themeMeta.setAttribute('content', isDark ? '#0f172a' : '#2563eb');
        }
    }
}
if (typeof prefersDark.addEventListener === 'function') {
    prefersDark.addEventListener('change', handleSystemThemeChange);
} else if (typeof prefersDark.addListener === 'function') {
    // Fallback para navegadores antigos
    prefersDark.addListener(handleSystemThemeChange);
}

// Função para destacar termos de busca
function highlightSearchTerm(text, searchTerm) {
    if (!searchTerm || searchTerm.length < 2 || !text) return text;
    
    const regex = new RegExp(`(${searchTerm.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi');
    return text.replace(regex, '<mark class="search-highlight">$1</mark>');
}

// Função para download do repositório
function downloadRepository(event) {
    event.preventDefault();
    
    try {
        // Verificar se há credenciais configuradas
        if (!app.credentials || !app.credentials.username || !app.credentials.token) {
            showNotification('Configure suas credenciais do GitHub primeiro!', 'warning');
            showSection('config-section');
            return;
        }


        
        // Verificar se há um repositório configurado no estado
        if (!app.credentials.repository) {
            showNotification('Selecione um repositório primeiro! Vá em "Meus Repositórios" e escolha um.', 'warning');
            showSection('repos-section');
            return;
        }
        
        // Mostrar loading
        const downloadBtn = event.target.closest('.download-button');
        const originalContent = downloadBtn.innerHTML;
        downloadBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Baixando...';
        downloadBtn.style.pointerEvents = 'none';
        
        // Iniciar download
        setTimeout(() => {
            const branch = app.settings.defaultBranch || 'main';
            const downloadUrl = `https://github.com/${app.credentials.username}/${app.credentials.repository}/archive/refs/heads/${branch}.zip`;
            
            const link = document.createElement('a');
            link.href = downloadUrl;
            link.download = `${app.credentials.repository}-${branch}.zip`;
            link.target = '_blank';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            
            downloadBtn.innerHTML = originalContent;
            downloadBtn.style.pointerEvents = 'auto';
            
            showNotification(`Download do repositório ${app.credentials.repository} iniciado!`, 'success');
            addLog('info', `Download do repositório ${app.credentials.repository} solicitado`);
        }, 800);
        
    } catch (error) {
        console.error('Erro no download:', error);
        showNotification('Erro ao iniciar download do repositório', 'error');
        addLog('error', `Erro no download: ${error.message}`);
        
        const downloadBtn = event.target.closest('.download-button');
        if (downloadBtn) {
            downloadBtn.innerHTML = '<i class="fas fa-download download-icon"></i><span>Baixar Repositório</span>';
            downloadBtn.style.pointerEvents = 'auto';
        }
    }
}
