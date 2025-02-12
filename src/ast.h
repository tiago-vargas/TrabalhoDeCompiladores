#ifndef AST_H
#define AST_H

#include <string>
#include <vector>

enum NodeType {
    NODE_PROGRAM,
    NODE_VAR_DECL,
    NODE_CONFIG,
    NODE_REPEAT,
    NODE_COMMANDS,
    NODE_IF,
    NODE_THEN,
    NODE_ELSE,
    NODE_WHILE,
    NODE_SERIAL,
    NODE_PWM,
    NODE_GPIO,
    NODE_WIFI,
    NODE_DELAY,
    NODE_ASSIGN,
    NODE_EXPR,
    NODE_TYPE,
    NODE_OPERATOR,
    NODE_NUMBER,
    NODE_STRING,
    NODE_BOOL,
    NODE_COMMAND
};

class Node {
public:
    NodeType type;
    std::string value;
    std::vector<Node*> children;

    Node(NodeType t, const std::string& v = "") : type(t), value(v) {}
    ~Node() {
        for (Node* child : children) {
            delete child;
        }
    }
};

#endif