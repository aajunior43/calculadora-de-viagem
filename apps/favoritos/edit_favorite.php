<?php
header('Content-Type: application/json');
require_once __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    requireWritePassword($data ?: []);
    ensureFavoritesFile();

    if (isset($data['oldName']) && isset($data['oldUrl']) && isset($data['name']) && isset($data['url'])) {
        // Validar URL
        if (!filter_var($data['url'], FILTER_VALIDATE_URL)) {
            echo json_encode(['success' => false, 'error' => 'URL inválida']);
            exit;
        }
        
        $content = file_get_contents(FAVORITES_FILE);
        $lines = explode("\n", $content);
        $new_content = [];
        $updated = false;
        
        foreach ($lines as $line) {
            if (trim($line) === "") {
                $new_content[] = $line;
                continue;
            }
            
            if (trim($line) === $data['oldName'] . "," . $data['oldUrl']) {
                $new_content[] = $data['name'] . "," . $data['url'];
                $updated = true;
            } else {
                $new_content[] = $line;
            }
        }
        
        if ($updated && file_put_contents(FAVORITES_FILE, implode("\n", $new_content), LOCK_EX) !== false) {
            echo json_encode(['success' => true]);
        } else {
            echo json_encode(['success' => false, 'error' => 'Erro ao atualizar arquivo ou item não encontrado']);
        }
    } else {
        echo json_encode(['success' => false, 'error' => 'Dados inválidos']);
    }
}
?>
