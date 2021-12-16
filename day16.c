#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <malloc.h>

enum typeid_t {
    T_SUM = 0,
    T_PRODUCT = 1,
    T_MINIMUM = 2,
    T_MAXIMUM = 3,
    T_LITERAL = 4,
    T_GREATER = 5,
    T_LESS = 6,
    T_EQUAL = 7,
};

enum part_t {
    P_GETVERSION,
    P_GETTYPE,
    P_GETLITERAL,
    P_GETOPSIZE_15,
    P_GETOPSIZE_11,
    P_DONE
};

struct packet {
    struct packet *subpackets[UINT8_MAX];
    uint64_t value;
    enum typeid_t type;
    uint8_t version;
    uint8_t top_subpacket;
};

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

uint8_t next_bit(FILE *handle, char *gotc, int8_t *bit_index) {
    /* Note - mutates current position in file! */
    /* To advance to next character, set bitindex to -1. */
    if ((*bit_index) < 0) {
        (*bit_index) = 3;
        (*gotc) = fgetc(handle);
    }
    if ((*gotc) == (char) EOF) return (uint8_t) EOF;
    return !!(hex_value(*gotc) & (1 << ((*bit_index)--)));
}

void add_subpacket(struct packet *dest, struct packet *sub) {
    dest->subpackets[(dest->top_subpacket)++] = sub;
}

uint32_t version_sum(struct packet *p) {
    uint32_t total = 0;
    total += (p->version);
    for (int i = 0; i < (p->top_subpacket); i++) {
        total += version_sum((p->subpackets)[i]);
    }
    return total;
}

size_t parse_into_packet( /* returns number of bits parsed */
    FILE *handle,
    struct packet *dest,
    char *gotc,
    int8_t *bit_index
) {
    size_t amount_parsed = 0;
    uint8_t bit;
    enum part_t stage = P_GETVERSION;
    bool done = false;
    uint64_t acc;
    while (!done) {
        switch (stage) {
        case P_GETVERSION:
        case P_GETTYPE:
            acc = 0;
            for (int i = 0; i < 3; i++) {
                bit = next_bit(handle, gotc, bit_index);
                acc = (acc << 1) + bit;
            }
            amount_parsed += 3;
            if (stage == P_GETVERSION) {
                dest->version = acc;
                stage = P_GETTYPE;
            } else { /* P_GETTYPE */
                dest->type = acc;
                if (acc == T_LITERAL) {
                    stage = P_GETLITERAL;
                } else {
                    bit = next_bit(handle, gotc, bit_index);
                    amount_parsed += 1;
                    if (bit) {
                        stage = P_GETOPSIZE_11;
                    } else {
                        stage = P_GETOPSIZE_15;
                    }
                }
            }
            break;
        case P_GETLITERAL:
            while (true) {
                acc = 0;
                for (int i = 0; i < 5; i++) {
                    bit = next_bit(handle, gotc, bit_index);
                    acc = (acc << 1) + bit;
                }
                amount_parsed += 5;
                dest->value = ((dest->value) << 4) + (acc & 0b1111);
                if (!(acc & 0b10000)) break;
            }
            stage = P_DONE;
            break;
        case P_GETOPSIZE_11: {
            /* acc is number of sub-packets */
            acc = 0;
            for (int i = 0; i < 11; i++) {
                bit = next_bit(handle, gotc, bit_index);
                acc = (acc << 1) + bit;
            }
            amount_parsed += 11;
            struct packet *new_packets = calloc(sizeof(struct packet), acc);
            for (int i = 0; i < acc; i++) {
                size_t res;
                res = parse_into_packet(handle, new_packets + i, gotc, bit_index);
                add_subpacket(dest, new_packets + i);
                amount_parsed += res;
            }
            stage = P_DONE;
            break;
        }
        case P_GETOPSIZE_15: {
            /* length, in bits, of sub-packets */
            acc = 0;
            for (int i = 0; i < 15; i++) {
                bit = next_bit(handle, gotc, bit_index);
                acc = (acc << 1) + bit;
            }
            amount_parsed += 15;
            size_t res = 0;
            while (res < acc) {
                struct packet *new_packet = calloc(sizeof(struct packet), 1);
                res += parse_into_packet(handle, new_packet, gotc, bit_index);
                add_subpacket(dest, new_packet);
            }
            amount_parsed += res;
            if (res != acc) {
                printf("WARNING! Too many bits!\n");
            }
            stage = P_DONE;
            break;
        }
        case P_DONE:
        default:
            done = true;
            break;
        }
    }
    return amount_parsed;
}

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
        if ((p->top_subpacket) == 0) printf("ERROR (MINIMUM)\n");
        acc = UINT64_MAX;
        for (int i = 0; i < (p->top_subpacket); i++) {
            uint64_t tmp = eval_packet((p->subpackets[i]));
            acc = (tmp < acc) ? tmp : acc;
        }
        return acc;
    case T_MAXIMUM:
        if ((p->top_subpacket) == 0) printf("ERROR (MAXIMUM)\n");
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
        case T_GREATER: printf(">");   break;
        case T_LESS:    printf("<");   break;
        case T_EQUAL:   printf("=");   break;
        default:        printf("???"); break;
        }
        for (int i = 0; i < (p->top_subpacket); i++) {
            printf(" ");
            print_expr((p->subpackets)[i]);
        }
        printf(")");
    }
}

int main(void) {
    FILE *input = fopen("input16.txt", "r");
    int8_t bit_index = -1;
    char gotc = 0;

    struct packet *p = calloc(sizeof(struct packet), 1);
    parse_into_packet(input, p, &gotc, &bit_index);
    fclose(input);

    /* part 1 */
    printf("%u\n", version_sum(p));
    /* part 2 */
    printf("%lu\n", eval_packet(p));

    /* bonus -- print AST */
    print_expr(p);
    printf("\n");

    return 0;
}
