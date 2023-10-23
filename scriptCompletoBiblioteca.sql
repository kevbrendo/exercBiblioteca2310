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

-- Inserts:

-- Inserts para a tabela Clientes
INSERT INTO Clientes (nome, endereco, telefone)
VALUES
    ('Cliente 1', 'Endereço 1', '123-456-7890'),
    ('Cliente 2', 'Endereço 2', '987-654-3210'),
    ('Cliente 3', 'Endereço 3', '555-123-4567'),
    ('Cliente 4', 'Endereço 4', '111-222-3333'),
    ('Cliente 5', 'Endereço 5', '999-888-7777'),
    ('Cliente 6', 'Endereço 6', '444-555-6666'),
    ('Cliente 7', 'Endereço 7', '777-888-9999'),
    ('Cliente 8', 'Endereço 8', '222-333-4444'),
    ('Cliente 9', 'Endereço 9', '666-777-8888'),
    ('Cliente 10', 'Endereço 10', '333-444-5555'),
    ('Cliente 11', 'Endereço 11', '123-456-7890'),
    ('Cliente 12', 'Endereço 12', '987-654-3210'),
    ('Cliente 13', 'Endereço 13', '555-123-4567'),
    ('Cliente 14', 'Endereço 14', '111-222-3333'),
    ('Cliente 15', 'Endereço 15', '999-888-7777'),
    ('Cliente 16', 'Endereço 16', '444-555-6666'),
    ('Cliente 17', 'Endereço 17', '777-888-9999'),
    ('Cliente 18', 'Endereço 18', '222-333-4444'),
    ('Cliente 19', 'Endereço 19', '666-777-8888'),
    ('Cliente 20', 'Endereço 20', '333-444-5555');

-- Inserts para a tabela Autores
INSERT INTO Autores (nome, data_nascimento, nacionalidade)
VALUES
    ('Autor 1', '1980-01-15', 'Nacionalidade 1'),
    ('Autor 2', '1975-07-20', 'Nacionalidade 2'),
    ('Autor 3', '1990-03-10', 'Nacionalidade 3'),
    ('Autor 4', '1985-11-30', 'Nacionalidade 4'),
    ('Autor 5', '1995-05-05', 'Nacionalidade 5'),
    ('Autor 6', '1982-09-25', 'Nacionalidade 1'),
    ('Autor 7', '1978-04-12', 'Nacionalidade 3'),
    ('Autor 8', '1989-06-18', 'Nacionalidade 2'),
    ('Autor 9', '1970-12-03', 'Nacionalidade 4'),
    ('Autor 10', '1992-08-08', 'Nacionalidade 5'),
    ('Autor 11', '1987-02-28', 'Nacionalidade 1'),
    ('Autor 12', '1972-10-14', 'Nacionalidade 3'),
    ('Autor 13', '1993-03-21', 'Nacionalidade 2'),
    ('Autor 14', '1974-07-02', 'Nacionalidade 4'),
    ('Autor 15', '1983-05-15', 'Nacionalidade 5'),
    ('Autor 16', '1998-09-08', 'Nacionalidade 1'),
    ('Autor 17', '1981-06-26', 'Nacionalidade 3'),
    ('Autor 18', '1976-08-22', 'Nacionalidade 2'),
    ('Autor 19', '1986-04-07', 'Nacionalidade 4'),
    ('Autor 20', '1973-11-10', 'Nacionalidade 5');

-- Inserts para a tabela Editoras
INSERT INTO Editoras (nome, endereco)
VALUES
    ('Editora 1', 'Endereço 1'),
    ('Editora 2', 'Endereço 2'),
    ('Editora 3', 'Endereço 3'),
    ('Editora 4', 'Endereço 4'),
    ('Editora 5', 'Endereço 5'),
    ('Editora 6', 'Endereço 6'),
    ('Editora 7', 'Endereço 7'),
    ('Editora 8', 'Endereço 8'),
    ('Editora 9', 'Endereço 9'),
    ('Editora 10', 'Endereço 10'),
    ('Editora 11', 'Endereço 11'),
    ('Editora 12', 'Endereço 12'),
    ('Editora 13', 'Endereço 13'),
    ('Editora 14', 'Endereço 14'),
    ('Editora 15', 'Endereço 15'),
    ('Editora 16', 'Endereço 16'),
    ('Editora 17', 'Endereço 17'),
    ('Editora 18', 'Endereço 18'),
    ('Editora 19', 'Endereço 19'),
    ('Editora 20', 'Endereço 20');

-- Inserts para a tabela Livros
INSERT INTO Livros (titulo, isbn, ano_publicacao, autor_id, editora_id)
VALUES
    ('Livro 1', 'ISBN-11111', 2020, 1, 1),
    ('Livro 2', 'ISBN-22222', 2018, 2, 2),
    ('Livro 3', 'ISBN-33333', 2019, 3, 1),
    ('Livro 4', 'ISBN-44444', 2021, 4, 3),
    ('Livro 5', 'ISBN-55555', 2017, 5, 4),
    ('Livro 6', 'ISBN-66666', 2016, 6, 5),
    ('Livro 7', 'ISBN-77777', 2022, 7, 6),
    ('Livro 8', 'ISBN-88888', 2015, 8, 7),
    ('Livro 9', 'ISBN-99999', 2019, 9, 8),
    ('Livro 10', 'ISBN-10101', 2023, 10, 9),
    ('Livro 11', 'ISBN-11112', 2014, 11, 10),
    ('Livro 12', 'ISBN-12121', 2020, 12, 11),
    ('Livro 13', 'ISBN-13131', 2018, 13, 12),
    ('Livro 14', 'ISBN-14141', 2016, 14, 13),
    ('Livro 15', 'ISBN-15151', 2022, 15, 14),
    ('Livro 16', 'ISBN-16161', 2017, 16, 15),
    ('Livro 17', 'ISBN-17171', 2021, 17, 16),
    ('Livro 18', 'ISBN-18181', 2019, 18, 17),
    ('Livro 19', 'ISBN-19191', 2015, 19, 18),
    ('Livro 20', 'ISBN-20202', 2023, 20, 19);

-- Inserts para a tabela Empréstimos
INSERT INTO Emprestimos (livro_id, cliente_id, data_emprestimo, data_devolucao, status)
VALUES
    (1, 1, '2023-10-23', '2023-10-30', 'pendente'),
    (2, 2, '2023-10-20', '2023-10-27', 'pendente'),
    (3, 3, '2023-10-18', '2023-10-25', 'pendente'),
    (4, 4, '2023-10-15', '2023-10-22', 'pendente'),
    (5, 5, '2023-10-12', '2023-10-19', 'pendente'),
    (6, 6, '2023-10-09', '2023-10-16', 'pendente'),
    (7, 7, '2023-10-06', '2023-10-13', 'pendente'),
    (8, 8, '2023-10-03', '2023-10-10', 'pendente'),
    (9, 9, '2023-09-30', '2023-10-07', 'pendente'),
    (10, 10, '2023-09-27', '2023-10-04', 'pendente'),
    (11, 11, '2023-09-24', '2023-10-01', 'pendente'),
    (12, 12, '2023-09-21', '2023-09-28', 'pendente'),
    (13, 13, '2023-09-18', '2023-09-25', 'pendente'),
    (14, 14, '2023-09-15', '2023-09-22', 'pendente'),
    (15, 15, '2023-09-12', '2023-09-19', 'pendente'),
    (16, 16, '2023-09-09', '2023-09-16', 'pendente'),
    (17, 17, '2023-09-06', '2023-09-13', 'pendente'),
    (18, 18, '2023-09-03', '2023-09-10', 'pendente'),
    (19, 19, '2023-08-31', '2023-09-07', 'pendente'),
    (20, 20, '2023-08-28', '2023-09-04', 'pendente');

