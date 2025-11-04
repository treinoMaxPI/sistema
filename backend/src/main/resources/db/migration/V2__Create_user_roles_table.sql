CREATE TABLE usuarios_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('ADMIN', 'PERSONAL', 'CUSTOMER')),
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    UNIQUE(usuario_id, role)
);

-- Create indexes for better performance
CREATE INDEX idx_usuarios_roles_usuario_id ON usuarios_roles(usuario_id);
CREATE INDEX idx_usuarios_roles_role ON usuarios_roles(role);