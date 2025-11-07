package senai.treinomax.api.controller;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.core.JsonProcessingException;
import lombok.RequiredArgsConstructor;
import senai.treinomax.api.auth.config.SecurityUtils;
import senai.treinomax.api.dto.response.PlanoCobrancaCustomerResponse;
import senai.treinomax.api.service.PlanoCobrancaService;

@RestController
@RequestMapping("/api/customer/cobrancas")
@RequiredArgsConstructor
public class PlanoCobrancaCustomerController {

    private final PlanoCobrancaService planoCobrancaService;

    @GetMapping
    @PreAuthorize("hasAnyRole('CUSTOMER')")
    public ResponseEntity<Page<PlanoCobrancaCustomerResponse>> getCustomerCobrancas(
            Pageable pageable) throws JsonProcessingException {
        Page<PlanoCobrancaCustomerResponse> cobrancas = planoCobrancaService.findCobrancasByUsuarioId(SecurityUtils.getCurrentUserId(), pageable)
                .map(PlanoCobrancaCustomerResponse::fromEntity);
        return ResponseEntity.ok(cobrancas);
    }
}