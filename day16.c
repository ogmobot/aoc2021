#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <malloc.h>

/*** enums and structs ***/

enum typeid_t {
    T_SUM     = 0,
    T_PRODUCT = 1,
    T_MINIMUM = 2,
    T_MAXIMUM = 3,
    T_LITERAL = 4,
    T_GREATER = 5,
    T_LESS    = 6,
    T_EQUAL   = 7,
};

struct packet {
    struct packet *subpackets[UINT8_MAX - 1];
    uint64_t value;
    enum typeid_t type;
    uint8_t version;
    uint8_t top_subpacket;
};

struct bit_reader {
    FILE *handle;
    char gotc;
    int8_t bit_index;
};

/*** parsing functions ***/

uint8_t hex_value(char mander) {
    switch (mander) {
    case '0': return  0; case '1': return  1;
    case '2': return  2; case '3': return  3;
    case '4': return  4; case '5': return  5;
    case '6': return  6; case '7': return  7;
    case '8': return  8; case '9': return  9;
    case 'A': return 10; case 'B': return 11;
    case 'C': return 12; case 'D': return 13;
    case 'E': return 14; case 'F': return 15;
    default: return UINT8_MAX;
    }
}

uint8_t next_bit(struct bit_reader *r) {
    if ((r->bit_index) < 0) {
        (r->bit_index) = 3;
        (r->gotc) = fgetc(r->handle);
    }
    if ((r->gotc) == (char) EOF) return (uint8_t) EOF;
    return !!(hex_value(r->gotc) & (1 << ((r->bit_index)--)));
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
    while (true) {
        uint8_t acc = 0;
        for (int i = 0; i < 5; i++) {
            acc = (acc << 1) + next_bit(r);
        }
        amount_parsed += 5;
        *dest = ((*dest) << 4) + (acc & 0b1111);
        if (!(acc & 0b10000)) break;
    }
    return amount_parsed;
}

void add_subpacket(struct packet *dest, struct packet *sub) {
    dest->subpackets[(dest->top_subpacket)++] = sub;
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
        for (int i = 0; i < (p->top_subpacket); i++)
            acc += eval_packet((p->subpackets)[i]);
        return acc;
    case T_PRODUCT:
        acc = 1;
        for (int i = 0; i < (p->top_subpacket); i++)
            acc *= eval_packet((p->subpackets)[i]);
        return acc;
    case T_MINIMUM:
        if ((p->top_subpacket) == 0) printf("ERROR (T_MINIMUM)\n");
        acc = UINT64_MAX;
        for (int i = 0; i < (p->top_subpacket); i++) {
            uint64_t tmp = eval_packet((p->subpackets[i]));
            acc = (tmp < acc) ? tmp : acc;
        }
        return acc;
    case T_MAXIMUM:
        if ((p->top_subpacket) == 0) printf("ERROR (T_MAXIMUM)\n");
        acc = 0;
        for (int i = 0; i < (p->top_subpacket); i++) {
            uint64_t tmp = eval_packet((p->subpackets[i]));
            acc = (tmp > acc) ? tmp : acc;
        }
        return acc;
    case T_LITERAL:
        return p->value;
    case T_GREATER:
        if ((p->top_subpacket) != 2) printf("ERROR (T_GREATER)\n");
        return eval_packet((p->subpackets)[0]) > eval_packet((p->subpackets)[1]);
    case T_LESS:
        if ((p->top_subpacket) != 2) printf("ERROR (T_LESS)\n");
        return eval_packet((p->subpackets)[0]) < eval_packet((p->subpackets)[1]);
    case T_EQUAL:
        if ((p->top_subpacket) != 2) printf("ERROR (T_EQUAL)\n");
        return eval_packet((p->subpackets)[0]) == eval_packet((p->subpackets)[1]);
    }
    /* This never happens */
    return UINT64_MAX;
}

uint32_t version_sum(struct packet *p) {
    uint32_t total = 0;
    total += (p->version);
    for (int i = 0; i < (p->top_subpacket); i++) {
        total += version_sum((p->subpackets)[i]);
    }
    return total;
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
        for (int i = 0; i < (p->top_subpacket); i++) {
            printf(" ");
            print_expr((p->subpackets)[i]);
        }
        printf(")");
    }
}

/*** main function ***/

int main(void) {
    FILE *input = fopen("input16.txt", "r");

    struct packet p     = {};
    struct bit_reader r = {input, '\0', -1};
    parse_into_packet(&r, &p);
    fclose(input);

    /* part 1 */
    printf("%u\n", version_sum(&p));
    /* part 2 */
    printf("%lu\n", eval_packet(&p));

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

    return 0;
}

/* On day 14, I said Clojure was one of the weirder LISPs I've used. But if
 * the AST in this problem counts as one, it's weirder yet.
 * Good ol' C seemed like a good option for the bithacking necessary to decode
 * the AST. I'm glad I didn't shoot myself in the foot... too many times ;)
 * (P.S. the allocated memory is only freed when the program exits. If you use
 * this code elsewhere, don't let it leak!)
 */
