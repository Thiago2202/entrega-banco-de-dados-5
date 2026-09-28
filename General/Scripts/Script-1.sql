create table usuarios(
	id int primary key,
	nome varchar(100) not null
);

create table livros(
	isbn varchar(20) primary key,
	titulo varchar(255) not null
);

create table emprestimo (
	id int primary key,
	usuarios_id int not null,
	livros_isbn vanchar(20) not null,
	
	constraint fk_usuarios
		foreign key (usuarios_id)
		references usuarios(id)
		on delete cascate,
		
		constraint fk_livros
		foreign key (livros_isbn)
		on delete cascade
	); 	