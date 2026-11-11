#include <irohnet.h>

#include <cstdio>
#include <cstdlib>

int main()
{
    SecretKey_t* secret = secret_key_generate();
    PublicKey_t key = secret_key_public(secret);
    char* key_str = public_key_as_base32(&key);
    std::printf("generated key:  %s\n", key_str);
    rust_free_string(key_str);
    public_key_free(key);

    EndpointConfig_t config = endpoint_config_default();
    endpoint_config_add_secret_key(&config, secret);  // takes ownership

    Endpoint_t* ep = endpoint_default();
    if (endpoint_bind(&config, nullptr, nullptr, &ep) != ENDPOINT_RESULT_OK) {
        std::fprintf(stderr, "endpoint_bind failed\n");
        return EXIT_FAILURE;
    }

    EndpointAddr_t addr = endpoint_addr_default();
    if (endpoint_addr(&ep, &addr) != ENDPOINT_RESULT_OK) {
        std::fprintf(stderr, "endpoint_addr failed\n");
        return EXIT_FAILURE;
    }
    char* id_str = public_key_as_base32(&addr.id);
    std::printf("endpoint id:    %s\n", id_str);
    std::printf("direct addrs:   %zu\n", addr.ip_addrs.len);
    rust_free_string(id_str);

    endpoint_addr_free(addr);
    endpoint_free(ep);
    endpoint_config_free(config);
    return EXIT_SUCCESS;
}
