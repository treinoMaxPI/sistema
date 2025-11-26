package senai.treinomax.api.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import senai.treinomax.api.model.Agendamento;

public interface AgendamentoRepository extends JpaRepository<Agendamento, UUID>{
    
}
