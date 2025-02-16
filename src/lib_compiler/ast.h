#ifndef _AST_H_
#define _AST_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct node *node_new(char *rule_name, char *text);
struct node *terminal_node(char *token_name);
void node_add_child(struct node *parent, struct node *child);
void print_ast(struct node *n, int depth);

struct node
{
	char *rule_name;
	char *text;
	struct node **children;
	int num_children;
	int capacity;
};

struct node *node_new(char *rule_name, char *text)
{
	struct node *n = malloc(sizeof(struct node));
	n->rule_name = strdup(rule_name);
	n->text = text;
	n->num_children = 0;
	n->capacity = 4;
	n->children = malloc(n->capacity * sizeof(struct node *));

	return n;
}

struct node *terminal_node(char *token_name)
{
	struct node *n = malloc(sizeof(struct node));
	char *formatted_token_name;
	asprintf(&formatted_token_name, "`%s`", token_name);
	n->rule_name = formatted_token_name;
	n->text = formatted_token_name;
	n->num_children = 0;
	n->capacity = 0;
	n->children = NULL;

	return n;
}

void node_add_child(struct node *parent, struct node *child)
{
	if (parent->num_children == parent->capacity)
	{
		parent->capacity *= 2;
		parent->children = realloc(parent->children, parent->capacity * sizeof(struct node *));
	}
	parent->children[parent->num_children++] = child;
}

void print_ast(struct node *n, int depth)
{
	if (NULL == n)
		return;

	for (int i = 0; i < depth - 1; ++i)
	{
		printf("  ");
	}
	printf("- ");
	printf("%s\n", n->rule_name);

	for (int i = 0; i < n->num_children; ++i)
	{
		print_ast(n->children[i], depth + 1);
	}
}
#endif
