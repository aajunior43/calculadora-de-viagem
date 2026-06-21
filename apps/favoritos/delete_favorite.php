<?php
header('Content-Type: application/json');
require_once __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    requireWritePassword($data ?: []);
    ensureFavoritesFile();

    if (isset($data['name']) && isset($data['url'])) {
        $content = file_get_contents(FAVORITES_FILE);
        $lines = explode("\n", $content);
        $new_content = [];
        
        foreach ($lines as $line) {
            if (trim($line) !== "" && $line !== ($data['name'] . "," . $data['url'])) {
                $new_content[] = $line;
            }
        }
        
        if (file_put_contents(FAVORITES_FILE, implode("\n", $new_content), LOCK_EX) !== false) {
            echo json_encode(['success' => true]);
        } else {
            echo json_encode(['success' => false, 'error' => 'Erro ao atualizar arquivo']);
        }
    } else {
        echo json_encode(['success' => false, 'error' => 'Dados inválidos']);
    }
}
?>
