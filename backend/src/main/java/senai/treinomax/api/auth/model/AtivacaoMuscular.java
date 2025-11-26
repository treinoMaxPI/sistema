package senai.treinomax.api.auth.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Entity
@Table(name = "ativacao_muscular")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AtivacaoMuscular {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @NotNull(message = "O grupo muscular é obrigatório.")
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private GrupoMuscular grupoMuscular;

    @Column(nullable = true)
    private Integer peso;

    @ManyToOne
    @JoinColumn(name = "exercicio_id")
    @JsonBackReference
    private Exercicio exercicio;

}