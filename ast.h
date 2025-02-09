#ifndef AST_H
#define AST_H

#include <string>
#include <vector>
#include <memory>

enum class NodeType {
    PROGRAM,
    DECLARATION,
    CONFIGURATION,
    COMMAND,
    EXPRESSION,
    IDENTIFIER,
    NUMBER,
    STRING
};

class ASTNode {
public:
    NodeType type;
    std::string value;
    std::vector<std::unique_ptr<ASTNode>> children;

    ASTNode(NodeType t, std::string v = "") : type(t), value(v) {}
    void addChild(std::unique_ptr<ASTNode> child) {
        children.push_back(std::move(child));
    }
};

#endif