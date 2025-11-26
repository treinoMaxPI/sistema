package senai.treinomax.api.auth.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Entity
@Table(name = "item_treino")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ItemTreino {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /**
     * Relação: Muitos ItensTreino pertencem a UM Treino.
     * Esta é a "chave estrangeira" para a tabela 'treino'.
     */
    @NotNull(message = "O item deve pertencer a um treino.")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "treino_id", nullable = false)
    @JsonIgnore // Evita referência circular na serialização JSON
    private Treino treino;

    /**
     * Relação: Muitos ItensTreino usam UM Exercício.
     * Esta é a "chave estrangeira" para a tabela 'exercicio'.
     */
    @NotNull(message = "O item deve conter um exercício.")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "exercicio_id", nullable = false)
    private Exercicio exercicio;

    @Positive(message = "A ordem deve ser um número positivo.")
    @Column(nullable = false)
    private Integer ordem; // Ex: 1 (primeiro exercício), 2 (segundo), etc.

    @Positive(message = "O número de séries deve ser positivo.")
    @Column(nullable = false)
    private Integer series; // Ex: 3

    @NotBlank(message = "A faixa de repetições é obrigatória.")
    @Size(max = 20, message = "Repetições deve ter no máximo 20 caracteres.")
    @Column(nullable = false, length = 20)
    private String repeticoes; // Ex: "10-12" ou "15"

    @Size(max = 50, message = "O tempo de descanso deve ter no máximo 50 caracteres.")
    @Column(length = 50)
    private String tempoDescanso; // Ex: "60s" ou "1min 30s"

    @Size(max = 255)
    private String observacao; // Ex: "Fazer com pegada supinada"
}