package senai.treinomax.api.model;

import java.time.LocalDateTime;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "agendamentos")
@NoArgsConstructor
@Data
@AllArgsConstructor
public class Agendamento {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne
    @JoinColumn(name = "aula_id", nullable = false)
    private Aula aula;

    @Column(name = "recorrente", nullable = false)
    private Boolean recorrente;

    @Column(name = "horario_recorrente", nullable = false)
    private Integer horarioRecorrente;
    
    @Size(min = 1, max = 7)
    @Column(name = "dia_recorrente", nullable = false)
    private Integer diaRecorrente;

    @Column(name = "data_exata", nullable = false)
    private LocalDateTime dataExata;


}
