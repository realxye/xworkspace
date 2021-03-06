#pragma once
#include <cstdint>
#include <string>
#include <vector>

namespace xbase {
namespace algorithm {

struct xbase64 {

    static const char* base64_encode_table()
    {
        static const char* etable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        return etable;
    }

    static const uint8_t* base64_dencode_table()
    {
        static const uint8_t dtable[256] = {
            //   00    01    02    03    04    05    06    07    08    09    0A    0B    0C    0D    0E    0F 
            /*00*/0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
            /*10*/0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
            /*20*/0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x3E, 0x80, 0x80, 0x80, 0x3F,
            /*30*/0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x80, 0x80, 0x80, 0x00, 0x80, 0x80,
            /*40*/0x80, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E,
            /*50*/0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x80, 0x80, 0x80, 0x80, 0x80,
            /*60*/0x80, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28,
            /*70*/0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32, 0x33, 0x80, 0x80, 0x80, 0x80, 0x80,
            /*80*/0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
            /*90*/0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
            /*A0*/0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
            /*B0*/0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
            /*C0*/0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
            /*D0*/0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
            /*E0*/0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
            /*F0*/0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        };

        return dtable;
    }

#ifdef _DEBUG
    static bool validate_decode_table()
    {
        const char* etable = xbase64::base64_encode_table();
        const uint8_t* dtable = xbase64::base64_dencode_table();
        for (int i = 0; i < 64; i++)
        {
            if (dtable[etable[i]] != (uint8_t)i)
                return false;
        }
        return true;
    }
#endif

    static std::string encode(const void* data, size_t size) noexcept
    {
        std::vector<char> result;
        const uint8_t* in = (const uint8_t*)data;
        const char* base64_table = xbase64::base64_encode_table();

        // Process full 3-bytes block
        while (size >= 3)
        {
            result.push_back(base64_table[in[0] >> 2]);
            result.push_back(base64_table[((in[0] & 0x03) << 4) | (in[1] >> 4)]);
            result.push_back(base64_table[((in[1] & 0x0f) << 2) | (in[2] >> 6)]);
            result.push_back(base64_table[in[2] & 0x3f]);
            in += 3;
            size -= 3;
        }

        // Process left (0, 1 or 2 bytes)
        if (0 != size)
        {
            result.push_back(base64_table[in[0] >> 2]);
            if (1 == size)
            {
                result.push_back(base64_table[(in[0] & 0x03) << 4]);
                result.push_back('=');
            }
            else
            {
                // size must be 2
                result.push_back(base64_table[((in[0] & 0x03) << 4) | (in[1] >> 4)]);
                result.push_back(base64_table[(in[1] & 0x0f) << 2]);
            }
            result.push_back('=');
        }

        return std::string(result.begin(), result.end());
    }

    static std::vector<uint8_t> decode(const std::string& sb64)
    {
        const uint8_t* dtable = xbase64::base64_dencode_table();
        const char* in = sb64.c_str();
        size_t len = sb64.length();
        std::vector<uint8_t> result;

        while (len >= 4)
        {
            const uint8_t block[4] = { dtable[in[0]], dtable[in[1]], dtable[in[2]], dtable[in[3]] };

            if(block[0] == 0x80 || block[1] == 0x80 || block[2] == 0x80 || block[3] == 0x80)
                throw std::invalid_argument("invalid content");
            if(block[0] == 0 || block[1] == 0)
                throw std::invalid_argument("too many padding");
            if (block[2] == 0 && block[3] != 0)
                throw std::invalid_argument("invalid padding");

            result.push_back((block[0] << 2) | (block[1] >> 4));
            if(block[2] != 0)   // at most 1 padding, which means at least one more valid bytes
                result.push_back((block[1] << 4) | (block[2] >> 2));
            if(block[3] != 0)   // no padding, which means one more valid bytes
                result.push_back((block[2] << 6) | block[3]);

            in += 4;
            len -= 4;
        }

        return result;
    }

    static std::vector<uint8_t> decode_nothrow(const std::string& sb64) noexcept
    {
        const uint8_t* dtable = xbase64::base64_dencode_table();
        const char* in = sb64.c_str();
        std::vector<uint8_t> result;

        auto read_block = [&](const char* in, uint8_t* block)->const char* {
            int count = 0;
            memset(block, 0x80, 4);
            while (count < 4 && *in) {
                if (dtable[*in] != 0x80)
                    block[count++] = dtable[*in];
                ++in;
            }
            return in;
        };

        while (*in)
        {
            uint8_t block[4] = { 0x80, 0x80, 0x80, 0x80 };
            in = read_block(in, block);

            if (block[0] == 0x80 || block[1] == 0x80 || block[2] == 0x80 || block[3] == 0x80)
                break;
            if (block[0] == 0 || block[1] == 0)
                break;
            if (block[2] == 0 && block[3] != 0)
                break;

            result.push_back((block[0] << 2) | (block[1] >> 4));
            if (block[2] != 0)   // at most 1 padding, which means at least one more valid bytes
                result.push_back((block[1] << 4) | (block[2] >> 2));
            if (block[3] != 0)   // no padding, which means one more valid bytes
                result.push_back((block[2] << 6) | block[3]);
        }

        return result;
    }

};

}}