package senai.treinomax.api.auth.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "treino")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Treino {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @NotBlank(message = "O nome do treino é obrigatório.")
    @Size(min = 3, max = 100, message = "O nome deve ter entre 3 e 100 caracteres.")
    @Column(nullable = false, length = 100)
    private String nome; // Ex: "Treino de Empurrar", "Treino de Puxar", "Leg Day"

    @Size(max = 50, message = "O tipo do treino deve ter no máximo 50 caracteres.")
    @Column(length = 50)
    private String tipoTreino; // Ex: "A", "B", "C", "Empurrar", "Puxar", "Leg Day"

    @Size(max = 500, message = "A descrição não pode exceder 500 caracteres.")
    @Column(length = 500)
    private String descricao;

    @Size(max = 50, message = "O nível deve ter no máximo 50 caracteres.")
    @Column(length = 50)
    private String nivel; // Ex: "Iniciante", "Intermediário", "Avançado"

    @OneToMany(mappedBy = "treino", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @OrderBy("ordem ASC")
    private List<ItemTreino> itens = new ArrayList<>();

    @ManyToOne
    @JoinColumn(name = "usuario_id")
    @JsonIgnoreProperties({ "senha", "roles", "plano", "proximoPlano", "dataCriacao", "dataAtualizacao" })
    private Usuario usuario;
}