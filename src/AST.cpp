#include "AST.hpp"

struct node_h* create_node(enum node_type_t type, char* val){
    struct node_h* new_node = new struct node_h;
    new_node->curr_type = type;
    if(val){
        new_node->value = val;
    } else{
        char empty[] = "";
        new_node->value = strdup(empty);
    }
    return new_node;
}

struct node_h* add_child(struct node_h* parent, struct node_h* child){
    parent->children.push_back(child);
    return parent;
}

void add_text_child(struct node_h* parent, char* text){
    struct node_h* new_child = create_node(text_t, text);
    add_child(parent, new_child);
}

void add_text(struct node_h* node, char* str){
    node->value = strcat(node->value, str);
}

void eval_root(char* fname, struct node_h* root){
    std::ofstream md_file;
    md_file.open(fname);
    eval(md_file, root);
    md_file.close();
}

void eval(std::ofstream &md_file, struct node_h* node){
    if(node->curr_type == verbatim_t){
        md_file << "\n```\n";
        md_file << node->value;
        md_file << "```\n";
        return;
    }
    if(node->curr_type == text_t){
        md_file << node->value;
    }
    else if(node->curr_type == bold_text_t){
        md_file << "**";
    } else if(node->curr_type == italics_text_t){
        md_file << "*";
    }
    for(struct node_h* child: node->children){
        eval(md_file, child);
    }
    if(node->curr_type == bold_text_t){
        md_file << "**";
    } else if(node->curr_type == italics_text_t){
        md_file << "*";
    }
}