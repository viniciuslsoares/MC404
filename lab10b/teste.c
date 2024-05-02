#include "lib.h"

#define NULL 0

int recursive_tree_search(struct Node* root, int target) {
    // Caso base: se a árvore estiver vazia, retorne 0 (valor não encontrado)
    if (root == NULL) {
        return 0;
    }

    // Caso base: se o valor for encontrado no nó atual, retorne 1
    if (root->val == target) {
        return 1;
    }

    // Recursivamente procure nas subárvores esquerda e direita
    int leftDepth = findDepth(root->left, target);
    if (leftDepth != 0) {
        return leftDepth + 1; // Adicione 1 à profundidade da subárvore esquerda
    }

    int rightDepth = findDepth(root->right, target);
    if (rightDepth != 0) {
        return rightDepth + 1; // Adicione 1 à profundidade da subárvore direita
    }

    // Se o valor não for encontrado, retorne 0
    return 0;
}