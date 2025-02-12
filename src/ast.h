#ifndef AST_H
#define AST_H

#include <string>
#include <vector>

enum NodeType {
    NODE_PROGRAM,
    NODE_VAR_DECL,
    NODE_CONFIG,
    NODE_REPEAT,
    NODE_IF,
    NODE_WHILE,
    NODE_SERIAL,
    NODE_DELAY,
    NODE_ASSIGN,
    NODE_PWM,
    NODE_PIN,
    NODE_WIFI,
    NODE_EXPR,
    NODE_NUMBER,
    NODE_STRING
};

struct Node {
    NodeType type;
    std::string value;
    std::vector<Node*> children;
    
    Node(NodeType t, std::string v = "") : type(t), value(v) {}
    ~Node() {
        for (Node* child : children) {
            delete child;
        }
    }
};

#endif