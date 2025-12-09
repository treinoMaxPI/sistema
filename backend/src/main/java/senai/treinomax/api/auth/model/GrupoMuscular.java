package senai.treinomax.api.auth.model;

public enum GrupoMuscular {
    PEITO,
    OMBRO,
    COSTAS,
    PERNA,
    GLUTEOS,
    TRICEPS,
    BICEPS,
    ABDOMEN;

    @Override
    public String toString() {
        return name();
    }   
}
