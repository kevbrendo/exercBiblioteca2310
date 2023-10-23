create database db_exerc_2310;
use db_exerc_2310;

-- Criação da tabela Autores
CREATE TABLE Autores (
    autor_id INT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    data_nascimento DATE,
    nacionalidade VARCHAR(100)
);

-- Criação da tabela Editoras
CREATE TABLE Editoras (
    editora_id INT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    endereco TEXT
);

-- Criação da tabela Clientes (para registrar informações sobre os clientes)
CREATE TABLE Clientes (
    cliente_id INT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    endereco TEXT,
    telefone VARCHAR(20)
);

-- Criação da tabela Livros
CREATE TABLE Livros (
    livro_id INT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    ano_publicacao INT,
    autor_id INT,
    editora_id INT,
    FOREIGN KEY (autor_id) REFERENCES Autores(autor_id),
    FOREIGN KEY (editora_id) REFERENCES Editoras(editora_id)
);

-- Criação da tabela Empréstimos
CREATE TABLE Emprestimos (
    emprestimo_id INT PRIMARY KEY,
    livro_id INT,
    cliente_id INT,
    data_emprestimo DATE,
    data_devolucao DATE,
    status ENUM('pendente', 'devolvido', 'atrasado') NOT NULL,
    FOREIGN KEY (livro_id) REFERENCES Livros(livro_id),
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
);
	
-- Stored Procedure para Registrar um Novo Empréstimo e Atualizar o Estoque:

DELIMITER //
CREATE PROCEDURE RegistrarEmprestimo(
    IN p_livro_id INT,
    IN p_cliente_id INT,
    IN p_data_emprestimo DATE,
    IN p_data_devolucao DATE,
    IN p_status ENUM('pendente', 'devolvido', 'atrasado')
)
BEGIN
    DECLARE estoque_atual INT;
    
    -- Verifica a disponibilidade do livro
    SELECT COUNT(*) INTO estoque_atual
    FROM Emprestimos
    WHERE livro_id = p_livro_id AND (status = 'pendente' OR status = 'atrasado');
    
    IF estoque_atual = 0 THEN
        -- Registra o empréstimo
        INSERT INTO Emprestimos (livro_id, cliente_id, data_emprestimo, data_devolucao, status)
        VALUES (p_livro_id, p_cliente_id, p_data_emprestimo, p_data_devolucao, p_status);
        
        SELECT 'Empréstimo registrado com sucesso.' AS mensagem;
    ELSE
        SELECT 'Este livro não está disponível para empréstimo no momento.' AS mensagem;
    END IF;
END;
//
DELIMITER ;

-- Stored Procedure para Recuperar a Lista de Livros Emprestados por um Cliente Específico:

DELIMITER //
CREATE PROCEDURE LivrosEmprestadosPorCliente(IN p_cliente_id INT)
BEGIN
    SELECT Livros.titulo, Emprestimos.data_emprestimo, Emprestimos.data_devolucao, Emprestimos.status
    FROM Emprestimos
    INNER JOIN Livros ON Emprestimos.livro_id = Livros.livro_id
    WHERE Emprestimos.cliente_id = p_cliente_id;
END;
//
DELIMITER ;


-- Stored Procedure para Calcular Multas para Empréstimos Atrasados (assumindo uma multa diária fixa):

DELIMITER //
CREATE PROCEDURE CalcularMultasAtrasadas()
BEGIN
    DECLARE valor_multa DECIMAL(10, 2);
    
    -- Defina o valor da multa por dia (ajuste conforme necessário)
    SET valor_multa = 2.00;
    
    -- Atualiza o status dos empréstimos atrasados
    UPDATE Emprestimos
    SET status = 'atrasado'
    WHERE data_devolucao < CURDATE() AND status = 'pendente';
    
    -- Calcula a multa para empréstimos atrasados
    UPDATE Emprestimos
    SET valor_multa = DATEDIFF(CURDATE(), data_devolucao) * valor_multa
    WHERE status = 'atrasado';
    
    SELECT 'Multas calculadas e empréstimos atualizados com sucesso.' AS mensagem;
END;
//
DELIMITER ;

-- View que Mostra os Livros Disponíveis para Empréstimo:

CREATE VIEW LivrosDisponiveis AS
SELECT L.titulo, L.isbn, L.ano_publicacao, A.nome AS autor, E.nome AS editora
FROM Livros L
INNER JOIN Autores A ON L.autor_id = A.autor_id
INNER JOIN Editoras E ON L.editora_id = E.editora_id
WHERE L.livro_id NOT IN (
    SELECT livro_id
    FROM Emprestimos
    WHERE status = 'pendente' OR status = 'atrasado'
);

-- View que Fornece uma Lista de Todos os Empréstimos Atuais:

CREATE VIEW ListaDeEmprestimos AS
SELECT E.emprestimo_id, L.titulo, C.nome AS cliente, E.data_emprestimo, E.data_devolucao, E.status
FROM Emprestimos E
INNER JOIN Livros L ON E.livro_id = L.livro_id
INNER JOIN Clientes C ON E.cliente_id = C.cliente_id;
