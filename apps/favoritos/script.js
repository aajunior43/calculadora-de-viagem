// Variáveis globais
let favorites = [];
let editMode = false;
let currentDeleteTarget = null;

// Carregar favoritos ao inicializar
document.addEventListener('DOMContentLoaded', function() {
    loadFavorites();
    
    // Configurar listeners de eventos
    document.querySelector('.search-input').addEventListener('input', filterFavorites);
    document.querySelector('.add-new-button').addEventListener('click', showAddForm);
    document.querySelector('.edit-mode-button').addEventListener('click', toggleEditMode);
});

// Carregar favoritos do servidor
function loadFavorites() {
    fetch('get_favorites.php')
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                favorites = data.favorites;
                renderFavorites();
            } else {
                showMessage(data.error || 'Erro ao carregar favoritos', 'error');
            }
        })
        .catch(error => {
            console.error('Erro:', error);
            showMessage('Erro ao conectar com o servidor', 'error');
        });
}

// Renderizar botões de favoritos
function renderFavorites() {
    const grid = document.querySelector('.button-grid');
    grid.innerHTML = '';
    
    favorites.forEach(favorite => {
        const buttonContainer = document.createElement('div');
        buttonContainer.className = 'site-button';
        
        const button = document.createElement('button');
        button.textContent = favorite.name;
        button.onclick = function() {
            if (!editMode) {
                window.open(favorite.url, '_blank');
            }
        };
        
        const editButton = document.createElement('button');
        editButton.className = 'edit-button';
        editButton.innerHTML = '✎';
        editButton.onclick = function(e) {
            e.stopPropagation();
            showEditForm(favorite.name, favorite.url);
        };
        
        const deleteButton = document.createElement('button');
        deleteButton.className = 'delete-button';
        deleteButton.innerHTML = '×';
        deleteButton.onclick = function(e) {
            e.stopPropagation();
            showPasswordModal(favorite.name, favorite.url);
        };
        
        buttonContainer.appendChild(button);
        buttonContainer.appendChild(editButton);
        buttonContainer.appendChild(deleteButton);
        
        grid.appendChild(buttonContainer);
    });
}

// Mostrar formulário de adição
function showAddForm() {
    document.querySelector('.add-link-form').style.display = 'block';
    document.getElementById('linkName').focus();
}

// Fechar formulário de adição
function closeForm() {
    document.querySelector('.add-link-form').style.display = 'none';
    document.getElementById('linkName').value = '';
    document.getElementById('linkUrl').value = '';
}

// Salvar novo link
function saveNewLink() {
    const name = document.getElementById('linkName').value.trim();
    const url = document.getElementById('linkUrl').value.trim();
    const password = document.getElementById('addPassword').value;
    
    if (!name || !url || !password) {
        showMessage('Preencha todos os campos', 'error');
        return;
    }
    
    fetch('save_favorite.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ name, url, password })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            closeForm();
            showMessage('Favorito adicionado com sucesso', 'success');
            loadFavorites();
        } else {
            showMessage(data.error || 'Erro ao salvar favorito', 'error');
        }
    })
    .catch(error => {
        console.error('Erro:', error);
        showMessage('Erro ao conectar com o servidor', 'error');
    });
}

// Alternar modo de edição
function toggleEditMode() {
    editMode = !editMode;
    document.querySelector('.button-grid').classList.toggle('edit-mode', editMode);
    document.querySelector('.edit-mode-button').style.backgroundColor = 
        editMode ? 'var(--primary-color)' : '';
    document.querySelector('.edit-mode-button').style.color = 
        editMode ? 'var(--primary-bg)' : '';
}

// Mostrar formulário de edição
function showEditForm(name, url) {
    document.querySelector('.edit-link-form').style.display = 'block';
    document.getElementById('editLinkName').value = name;
    document.getElementById('editLinkUrl').value = url;
    
    // Armazenar valores originais como atributos personalizados
    document.getElementById('editLinkName').setAttribute('data-original', name);
    document.getElementById('editLinkUrl').setAttribute('data-original', url);
}

// Fechar formulário de edição
function closeEditForm() {
    document.querySelector('.edit-link-form').style.display = 'none';
}

// Salvar link editado
function saveEditLink() {
    const oldName = document.getElementById('editLinkName').getAttribute('data-original');
    const oldUrl = document.getElementById('editLinkUrl').getAttribute('data-original');
    const newName = document.getElementById('editLinkName').value.trim();
    const newUrl = document.getElementById('editLinkUrl').value.trim();
    
    if (!newName || !newUrl) {
        showMessage('Preencha todos os campos', 'error');
        return;
    }
    
    // Mostrar prompt para senha
    const password = prompt('Digite a senha para confirmar a edição:');
    if (!password) return;
    
    fetch('edit_favorite.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ 
            oldName, 
            oldUrl, 
            name: newName, 
            url: newUrl,
            password 
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            closeEditForm();
            showMessage('Favorito atualizado com sucesso', 'success');
            loadFavorites();
        } else {
            showMessage(data.error || 'Erro ao atualizar favorito', 'error');
        }
    })
    .catch(error => {
        console.error('Erro:', error);
        showMessage('Erro ao conectar com o servidor', 'error');
    });
}

// Mostrar modal de senha para exclusão
function showPasswordModal(name, url) {
    currentDeleteTarget = { name, url };
    document.querySelector('.password-modal').style.display = 'block';
    document.getElementById('deletePassword').focus();
}

// Fechar modal de senha
function closePasswordModal() {
    document.querySelector('.password-modal').style.display = 'none';
    document.getElementById('deletePassword').value = '';
    currentDeleteTarget = null;
}

// Confirmar exclusão com senha
function confirmDelete() {
    const password = document.getElementById('deletePassword').value.trim();
    
    if (!password) {
        showMessage('Digite a senha', 'error');
        return;
    }
    
    if (!currentDeleteTarget) {
        closePasswordModal();
        return;
    }
    
    fetch('delete_favorite.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ 
            name: currentDeleteTarget.name, 
            url: currentDeleteTarget.url,
            password 
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            closePasswordModal();
            showMessage('Favorito excluído com sucesso', 'success');
            loadFavorites();
        } else {
            showMessage(data.error || 'Erro ao excluir favorito', 'error');
        }
    })
    .catch(error => {
        console.error('Erro:', error);
        showMessage('Erro ao conectar com o servidor', 'error');
    });
}

// Filtrar favoritos
function filterFavorites() {
    const query = document.querySelector('.search-input').value.toLowerCase();
    
    const allButtons = document.querySelectorAll('.site-button');
    allButtons.forEach(buttonContainer => {
        const buttonText = buttonContainer.querySelector('button').textContent.toLowerCase();
        
        if (buttonText.includes(query)) {
            buttonContainer.style.display = 'block';
        } else {
            buttonContainer.style.display = 'none';
        }
    });
}

// Baixar lista de favoritos
function downloadFavorites() {
    window.location.href = 'download_favorites.php';
}

// Mostrar mensagem de feedback
function showMessage(text, type) {
    const message = document.createElement('div');
    message.className = `message ${type}`;
    message.textContent = text;
    
    document.body.appendChild(message);
    
    setTimeout(() => {
        message.remove();
    }, 3000);
                }
