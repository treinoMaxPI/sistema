package senai.treinomax.api.controller;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import com.fasterxml.jackson.databind.ObjectMapper;

import senai.treinomax.api.auth.config.JwtAuthenticationFilter;
import senai.treinomax.api.auth.model.Usuario;
import senai.treinomax.api.auth.repository.UsuarioRepository;
import senai.treinomax.api.auth.service.CustomUserDetailsService;
import senai.treinomax.api.auth.service.CustomUserDetailsService.CustomUserDetails;
import senai.treinomax.api.auth.service.TokenService;
import senai.treinomax.api.auth.service.UsuarioService;
import senai.treinomax.api.dto.request.AgendamentoRequest;
import senai.treinomax.api.dto.request.AulaRequest;
import senai.treinomax.api.dto.response.AulaResponse;
import senai.treinomax.api.dto.response.CategoriaResponse;
import senai.treinomax.api.model.Aula;
import senai.treinomax.api.model.Categoria;
import senai.treinomax.api.model.Plano;
import senai.treinomax.api.service.AulaService;

@WebMvcTest(AulaController.class)
@AutoConfigureMockMvc(addFilters = false)
class AulaControllerTest {

        @Autowired
        private MockMvc mockMvc;

        @MockitoBean
        private AulaService aulaService;

        @MockitoBean
        private UsuarioService usuarioService;

        @MockitoBean
        private UsuarioRepository usuarioRepository;

        @MockitoBean
        private CustomUserDetailsService customUserDetailsService;

        @MockitoBean
        private JwtAuthenticationFilter jwtAuthenticationFilter;

        @MockitoBean
        private TokenService tokenService;

        @Autowired
        private ObjectMapper objectMapper;

        private Aula aula;
        private AulaResponse aulaResponse;
        private AulaRequest aulaRequest;
        private Usuario usuario;

        @BeforeEach
        void setUp() {
                usuario = new Usuario();
                usuario.setId(UUID.randomUUID());
                usuario.setEmail("test@example.com");
                usuario.setNome("Test User");

                Categoria categoria = new Categoria();
                categoria.setId(UUID.randomUUID());
                categoria.setNome("Musculação");

                aula = new Aula();
                aula.setId(UUID.fromString("123e4567-e89b-12d3-a456-426614174000"));
                aula.setTitulo("Aula 1");
                aula.setDescricao("Descrição Aula 1");
                aula.setBannerUrl("http://banner.url");
                aula.setDuracao(60);
                aula.setCategoria(categoria);
                aula.setUsuarioPersonal(usuario);

                CategoriaResponse categoriaResponse = new CategoriaResponse(categoria.getId(), categoria.getNome(),
                                null);
                aulaResponse = new AulaResponse(aula.getId(), "Aula 1", "Descrição Aula 1", "http://banner.url", 60,
                                categoriaResponse, "Test User", null);

                aulaRequest = new AulaRequest();
                aulaRequest.setTitulo("Aula 1");
                aulaRequest.setDescricao("Descrição Aula 1");
                aulaRequest.setBannerUrl("http://banner.url");
                aulaRequest.setDuracao(60);
                aulaRequest.setCategoriaId(categoria.getId());

                AgendamentoRequest agendamentoRequest = new AgendamentoRequest();
                agendamentoRequest.setRecorrente(false);
                agendamentoRequest.setDataExata(LocalDateTime.now().plusDays(1));
                aulaRequest.setAgendamento(agendamentoRequest);
        }

        @Test
        @WithMockUser(roles = "PERSONAL")
        void criar_ShouldReturnCreated_WhenValidRequest() throws Exception {
                when(usuarioService.buscarPorEmail(anyString())).thenReturn(usuario);
                when(aulaService.salvar(any(AulaRequest.class), any(UUID.class))).thenReturn(aula);

                mockMvc.perform(post("/api/aulas")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(aulaRequest))
                                .with(csrf()))
                                .andExpect(status().isCreated())
                                .andExpect(jsonPath("$.id").value(aula.getId().toString()))
                                .andExpect(jsonPath("$.titulo").value(aula.getTitulo()));
        }

        @Test
        @WithMockUser(roles = "CUSTOMER")
        void buscarPorId_ShouldReturnAula_WhenExists() throws Exception {
                when(aulaService.buscarPorId("123e4567-e89b-12d3-a456-426614174000")).thenReturn(aula);

                mockMvc.perform(get("/api/aulas/{id}", "123e4567-e89b-12d3-a456-426614174000"))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.id").value(aula.getId().toString()))
                                .andExpect(jsonPath("$.titulo").value(aula.getTitulo()));
        }

        @Test
        @WithMockUser
        void listarTodas_ShouldReturnList_WhenCalled() throws Exception {
                when(aulaService.listarTodas()).thenReturn(List.of(aula));

                mockMvc.perform(get("/api/aulas"))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$[0].id").value(aula.getId().toString()))
                                .andExpect(jsonPath("$[0].titulo").value(aula.getTitulo()));
        }

        @Test
        void listarAulasDoAluno_ShouldReturnList_WhenUserHasPlan() throws Exception {
                // Setup CustomUserDetails for SecurityUtils.getCurrentUser
                CustomUserDetails userDetails = new CustomUserDetails(
                                usuario.getId(),
                                usuario.getEmail(),
                                usuario.getSenha(),
                                true,
                                Collections.singletonList(new SimpleGrantedAuthority("ROLE_CUSTOMER")));

                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                                userDetails, null, userDetails.getAuthorities());

                SecurityContextHolder.getContext().setAuthentication(authentication);

                Plano plano = new Plano();
                plano.setId(UUID.randomUUID());
                usuario.setPlano(plano);

                when(usuarioRepository.findById(usuario.getId())).thenReturn(java.util.Optional.of(usuario));
                when(aulaService.listarPorPlano(plano.getId())).thenReturn(List.of(aula));

                mockMvc.perform(get("/api/aulas/minhas"))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$[0].id").value(aula.getId().toString()));
        }

        @Test
        @WithMockUser(roles = "PERSONAL")
        void atualizar_ShouldReturnUpdatedAula_WhenExists() throws Exception {
                when(aulaService.atualizar(eq("123e4567-e89b-12d3-a456-426614174000"), any(AulaRequest.class)))
                                .thenReturn(aula);

                mockMvc.perform(put("/api/aulas/{id}", "123e4567-e89b-12d3-a456-426614174000")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(aulaRequest))
                                .with(csrf()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.id").value(aula.getId().toString()));
        }

        @Test
        @WithMockUser(roles = "PERSONAL")
        void deletar_ShouldReturnNoContent_WhenExists() throws Exception {
                doNothing().when(aulaService).deletarPorId("123e4567-e89b-12d3-a456-426614174000");

                mockMvc.perform(delete("/api/aulas/{id}", "123e4567-e89b-12d3-a456-426614174000")
                                .with(csrf()))
                                .andExpect(status().isNoContent());
        }

        @Test
        @WithMockUser(roles = "PERSONAL")
        void uploadImagem_ShouldReturnPath_WhenSuccessful() throws Exception {
                MockMultipartFile file = new MockMultipartFile("file", "test.jpg", MediaType.IMAGE_JPEG_VALUE,
                                "test image content".getBytes());
                when(aulaService.salvarImagem(any())).thenReturn("/path/to/image.jpg");

                mockMvc.perform(multipart("/api/aulas/upload")
                                .file(file)
                                .with(csrf()))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$").value("/path/to/image.jpg"));
        }

        @Test
        @WithMockUser
        void downloadImagem_ShouldReturnResource_WhenExists() throws Exception {

                Resource mockResource = new ByteArrayResource("content".getBytes()) {
                        @Override
                        public String getFilename() {
                                return "test.jpg";
                        }
                };

                when(aulaService.carregarImagem("test.jpg")).thenReturn(mockResource);

                mockMvc.perform(get("/api/aulas/uploads/{filename}", "test.jpg"))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$").exists());
        }
}
