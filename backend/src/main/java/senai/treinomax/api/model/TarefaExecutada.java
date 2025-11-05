package senai.treinomax.api.model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import senai.treinomax.api.util.DateUtils;

@Entity
@Table(name = "tarefas_executadas")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TarefaExecutada {
    public enum TarefaTipo {
        MENSAL_VERIFICAR_PLANOS
    }
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TarefaTipo tipo;
    
    @Column(nullable = false)
    private Boolean sucesso;
    
    @Column(length = 1000)
    private String mensagemErro;
    
    @Column(nullable = false, updatable = false)
    private LocalDateTime dataHoraExecucao;
    
    @Column(nullable = false, updatable = false)
    private LocalDate diaExecucao;
    
    public void setMensagemErro(String mensagemErro) {
        this.mensagemErro = mensagemErro != null && mensagemErro.length() > 1000 
            ? mensagemErro.substring(0, 1000) 
            : mensagemErro;
    } 

}
