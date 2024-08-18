#ifndef __AST_H__
#define __AST_H__

#include <iostream>
#include <fstream>

enum node_type_t{
    preamble_t,
    body_t, 
    text_t,
    bold_text_t,
    italics_text_t,
    verbatim_t
};

struct node_h{
    enum node_type_t curr_type;
    std::vector<node_h*> children; 
    char* value;
};

struct node_h* create_node(enum node_type_t type, char* val = NULL);
struct node_h* add_child(struct node_h* parent, struct node_h* child);
void add_text_child(struct node_h* parent, char* text);
void add_text(struct node_h* node, char* str);

void eval_root(char* fname, struct node_h* root);
void eval(std::ofstream &md_file, struct node_h* node);

#endif