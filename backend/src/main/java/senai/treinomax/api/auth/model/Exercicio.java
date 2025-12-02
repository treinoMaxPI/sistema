package senai.treinomax.api.auth.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonManagedReference;
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
@Table(name = "exercicio")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Exercicio {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @NotBlank(message = "O nome do exercício é obrigatório.")
    @Size(min = 3, max = 100, message = "O nome deve ter entre 3 e 100 caracteres.")
    @Column(nullable = false, length = 100, unique = true)
    private String nome;

    @Size(max = 500, message = "A descrição não pode exceder 500 caracteres.")
    @Column(length = 500)
    private String descricao;

    @OneToMany(mappedBy = "exercicio", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    @JsonManagedReference
    @JsonIgnoreProperties("exercicio")
    private List<AtivacaoMuscular> ativacaoMuscular = new ArrayList<>();

    @Size(max = 255, message = "A URL do vídeo não pode exceder 255 caracteres.")
    @Column(length = 255)
    private String videoUrl;
}