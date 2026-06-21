<?php

const FAVORITES_DATA_DIR = __DIR__ . '/data';
const FAVORITES_FILE = FAVORITES_DATA_DIR . '/favorites.txt';

function ensureFavoritesFile(): void
{
    if (!is_dir(FAVORITES_DATA_DIR)) {
        mkdir(FAVORITES_DATA_DIR, 0770, true);
    }

    if (!file_exists(FAVORITES_FILE)) {
        touch(FAVORITES_FILE);
    }
}

function requireWritePassword(array $data): void
{
    $configuredPassword = getenv('FAVORITES_PASSWORD');
    $providedPassword = isset($data['password']) ? (string) $data['password'] : '';

    if (!$configuredPassword || !hash_equals($configuredPassword, $providedPassword)) {
        http_response_code(403);
        echo json_encode(['success' => false, 'error' => 'Senha incorreta']);
        exit;
    }
}

