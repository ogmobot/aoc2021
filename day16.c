#include <stdio.h>
#include <stdint.h>
#include <malloc.h>

/*** enums and structs ***/

struct packet {
    struct packet *sibling;
    union {
        struct packet *child;
        uint64_t value;
    };
    enum {
        T_SUM     = 0, T_PRODUCT = 1,
        T_MINIMUM = 2, T_MAXIMUM = 3,
        T_LITERAL = 4, T_GREATER = 5,
        T_LESS    = 6, T_EQUAL   = 7,
    } type;
    uint8_t version;
};

struct bit_reader {
    FILE *handle;
    uint8_t gotu8;
    int8_t bit_index;
};

/*** parsing functions ***/

uint8_t next_bit(struct bit_reader *r) {
    if ((r->bit_index) < 0) {
        (r->bit_index) = 7;
        fscanf(r->handle, "%2hhx", &(r->gotu8));
    }
    return !!((r->gotu8) & (1 << ((r->bit_index)--)));
}

uint8_t parse_bits_u8(struct bit_reader *r, int n) {
    uint8_t acc = 0;
    uint8_t bit;
    for (int i = 0; i < n; i++) {
        bit = next_bit(r);
        acc = (acc << 1) | bit;
    }
    return acc;
}

uint64_t parse_bits_u64(struct bit_reader *r, int n) {
    uint64_t acc = 0;
    uint8_t bit;
    for (int i = 0; i < n; i++) {
        bit = next_bit(r);
        acc = (acc << 1) | bit;
    }
    return acc;
}

size_t parse_into_literal(struct bit_reader *r, uint64_t *dest) {
    /* returns number of bits parsed */
    size_t amount_parsed = 0;
    while (1) {
        uint8_t acc = 0;
        for (int i = 0; i < 5; i++) {
            acc = (acc << 1) + next_bit(r);
        }
        amount_parsed += 5;
        *dest = ((*dest) << 4) + (acc & 0x0F);
        if (!(acc & 0x10)) break;
    }
    return amount_parsed;
}

void add_subpacket(struct packet *dest, struct packet *sub) {
    /* this prepends the list, so comparision tests will look odd */
    sub->sibling = dest->child;
    dest->child = sub;
}

size_t parse_into_packet(struct bit_reader *r, struct packet *dest) {
    /* returns number of bits parsed */
    size_t amount_parsed = 0;

    dest->version = parse_bits_u8(r, 3);
    dest->type    = parse_bits_u8(r, 3);
    amount_parsed += 6;
    if (dest->type == T_LITERAL) {
        amount_parsed += parse_into_literal(r, &(dest->value));
    } else {
        amount_parsed += 1;
        if (next_bit(r)) { /* length type id = 1 */
            int npackets = parse_bits_u64(r, 11);
            amount_parsed += 11;
            for (int i = 0; i < npackets; i++) {
                struct packet *new_packet = calloc(sizeof(struct packet), 1);
                size_t res = parse_into_packet(r, new_packet);
                add_subpacket(dest, new_packet);
                amount_parsed += res;
            }
        } else { /* length type id = 0 */
            int nbits = parse_bits_u64(r, 15);
            amount_parsed += 15;
            size_t res = 0;
            while (res < nbits) {
                struct packet *new_packet = calloc(sizeof(struct packet), 1);
                res += parse_into_packet(r, new_packet);
                add_subpacket(dest, new_packet);
            }
            amount_parsed += res;
            if (res != nbits) printf("WARNING! Too many bits!\n");
        }
    }
    return amount_parsed;
}

/*** logic functions ***/

uint64_t eval_packet(struct packet *p) {
    uint64_t acc;
    switch (p->type) {
    case T_SUM:
        acc = 0;
        for (struct packet *q = p->child; q != (void *) 0; q = q->sibling)
            acc += eval_packet(q);
        return acc;
    case T_PRODUCT:
        acc = 1;
        for (struct packet *q = p->child; q != (void *) 0; q = q->sibling)
            acc *= eval_packet(q);
        return acc;
    case T_MINIMUM:
        acc = UINT64_MAX;
        for (struct packet *q = p->child; q != (void *) 0; q = q->sibling) {
            uint64_t tmp = eval_packet(q);
            acc = (tmp < acc) ? tmp : acc;
        }
        return acc;
    case T_MAXIMUM:
        acc = 0;
        for (struct packet *q = p->child; q != (void *) 0; q = q->sibling) {
            uint64_t tmp = eval_packet(q);
            acc = (tmp > acc) ? tmp : acc;
        }
        return acc;
    case T_LITERAL:
        return p->value;
    case T_GREATER:
    case T_LESS:
    case T_EQUAL: {
        struct packet *second = p->child;
        struct packet *first  = second->sibling;
        if (first->sibling != (void *) 0) printf("ERROR IN COMPARATOR\n");
        switch (p->type) {
        case T_GREATER: return eval_packet(first)  > eval_packet(second);
        case T_LESS:    return eval_packet(first)  < eval_packet(second);
        case T_EQUAL:   return eval_packet(first) == eval_packet(second);
        default:        return UINT64_MAX;
        }
    }}
    /* This never happens */
    return UINT64_MAX;
}

uint32_t version_sum(struct packet *p) {
    uint32_t total = 0;
    total += (p->version);
    if (p->type != T_LITERAL) {
        for (struct packet *q = p->child; q != (void *) 0; q = q->sibling) {
            total += version_sum(q);
        }
    }
    return total;
}

void free_all(struct packet *p) {
    if (!p) return;
    if (p->type != T_LITERAL) {
        free_all(p->child);
    }
    free_all(p->sibling);
    free(p);
    return;
}

void print_expr(struct packet *p) {
    if (p->type == T_LITERAL) {
        printf("%lu", p->value);
    } else {
        printf("(");
        switch (p->type) {
        case T_SUM:     printf("+");   break;
        case T_PRODUCT: printf("*");   break;
        case T_MINIMUM: printf("MIN"); break;
        case T_MAXIMUM: printf("MAX"); break;
        case T_GREATER: printf("GT");  break;
        case T_LESS:    printf("LT");  break;
        case T_EQUAL:   printf("EX");  break;
        default:        printf("???"); break;
        }
        for (struct packet *q = p->child; q != (void *) 0; q = q->sibling) {
            printf(" ");
            print_expr(q);
        }
        printf(")");
    }
}

/*** main function ***/

int main(void) {
    FILE *input = fopen("input16.txt", "r");

    struct packet *p    = calloc(sizeof(struct packet), 1);
    struct bit_reader r = {input, '\0', -1};
    parse_into_packet(&r, p);
    fclose(input);

    /* part 1 */
    printf("%u\n", version_sum(p));
    /* part 2 */
    printf("%lu\n", eval_packet(p));

    /* bonus -- print AST */
    /*
    printf(
        "(defun lt (a b) (if (< a b) 1 0))\n"
        "(defun gt (a b) (if (> a b) 1 0))\n"
        "(defun ex (a b) (if (= a b) 1 0))\n"
    );
    print_expr(p);
    printf("\n");
    */

    free_all(p);
    return 0;
}

/* On day 14, I said Clojure was one of the weirder LISPs I've used. But if
 * the AST in this problem counts as one, it's weirder yet.
 * Good ol' C seemed like a good option for the bithacking necessary to decode
 * the AST. I'm glad I didn't shoot myself in the foot... too many times ;)
 */
