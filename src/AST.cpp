/**
 * @file AST.cpp
 * @author Yash Solanki (252yash@gmail.com)
 * @brief Abstract Syntax Tree (AST) implementation for processing Markdown-like text structures.
 * @version 0.1
 * @date 2024-08-25
 * 
 * @copyright Copyright (c) 2024
 */
#include "AST.hpp"

/**
 * @brief Creates a new AST node of the given type enum and with a string value 'val'.
 * 
 * @param type The type of the node (e.g., section, text, verbatim, etc.).
 * @param val The value of the node. If NULL, an empty string is used.
 * @return struct node_h* Pointer to the newly created node.
 */
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

/**
 * @brief Adds a child node to the given parent node.
 * 
 * @param parent Pointer to the parent node.
 * @param child Pointer to the child node to be added.
 * @return struct node_h* Pointer to the parent node with the newly added child.
 */
struct node_h* add_child(struct node_h* parent, struct node_h* child){
    parent->children.push_back(child);
    return parent;
}

/**
 * @brief Creates a text node and adds it as a child to the parent node.
 * 
 * @param parent Pointer to the parent node.
 * @param text The text to be added as a new child node.
 */
void add_text_child(struct node_h* parent, char* text){
    struct node_h* new_child = create_node(text_t, text);
    add_child(parent, new_child);
}

/**
 * @brief Appends text to an existing node's value.
 * 
 * @param node Pointer to the node whose value will be updated.
 * @param str The string to append to the node's value.
 */
void add_text(struct node_h* node, char* str){
    node->value = strcat(node->value, str);
}

/**
 * @brief Evaluates the root of the AST and writes the output to a file.
 * 
 * @param fname The name of the output markdown file.
 * @param root Pointer to the root node of the AST.
 */
void eval_root(char* fname, struct node_h* root){
    std::ofstream md_file;
    md_file.open(fname);
    eval(md_file, root);
    md_file.close();
}

/**
 * @brief Recursively evaluates an AST node and writes the corresponding Markdown output.
 * 
 * @param md_file Reference to the output file stream.
 * @param node Pointer to the AST node to be evaluated.
 */
void eval(std::ofstream &md_file, struct node_h* node){
    if(node->curr_type == verbatim_t){
        md_file << "\n```\n";
        int len = strlen(node->value);
        md_file << node->value;
        if(node->value[len - 1] != '\n'){
            md_file << "\n";
        }
        md_file << "```\n";
        return;
    }
    if(node->curr_type == href_t){
        md_file << '[';
        eval(md_file, node->children[1]);
        md_file << ']';
        md_file << '(';
        eval(md_file, node->children[0]);
        md_file << ')';
        return;
    }
    if(node->curr_type == image_t){
        md_file << '!' << '[' << ']' << '(';
        eval(md_file, node->children[0]);
        md_file << ')';
        return;
    }
    if(node->curr_type == section_t){
        md_file << '\n' <<  "# ";
    }
    if(node->curr_type == subsection_t){
        md_file << '\n' << "## ";
    }
    if(node->curr_type == subsubsection_t){
        md_file << '\n' << "### ";
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
    if(node->curr_type == section_t){
        md_file << '\n';
    }
    if(node->curr_type == subsection_t){
        md_file << '\n';
    }
    if(node->curr_type == subsubsection_t){
        md_file << '\n';
    }
}

/**
 * @brief Prepends a string to another string.
 * 
 * @param s The original string to which the prefix is added.
 * @param t The prefix string.
 * @return char* The resulting string with the prefix added.
 */
char* prepend(char* s, const char* t) {
    size_t len = strlen(t);
    memmove(s + len, s, strlen(s) + 1);
    memcpy(s, t, len);
    return s;
}