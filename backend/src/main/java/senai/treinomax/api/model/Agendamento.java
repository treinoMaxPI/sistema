package senai.treinomax.api.model;

import java.time.LocalDateTime;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

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

    @OneToOne
    @JoinColumn(name = "aula_id", nullable = false)
    private Aula aula;

    @Column(name = "recorrente", nullable = false)
    private Boolean recorrente;

    @Column(name = "horario_recorrente", nullable = true)
    private Integer horarioRecorrente;

    @Column(name = "segunda", nullable = true)
    private Boolean segunda;

    @Column(name = "terca", nullable = true)
    private Boolean terca;

    @Column(name = "quarta", nullable = true)
    private Boolean quarta;

    @Column(name = "quinta", nullable = true)
    private Boolean quinta;

    @Column(name = "sexta", nullable = true)
    private Boolean sexta;

    @Column(name = "sabado", nullable = true)
    private Boolean sabado;

    @Column(name = "domingo", nullable = true)
    private Boolean domingo;

    @Column(name = "data_exata", nullable = true)
    private LocalDateTime dataExata;

}
