#ifndef __AST_H__
#define __AST_H__

#include <iostream>

enum node_type_t{
    preamble_t,
    body_t, 
    sentence_t
};

struct node_h{
    enum node_type_t curr_type;
    struct node_h *left;
    struct node_h *right;
    std::string value;
};

#endif