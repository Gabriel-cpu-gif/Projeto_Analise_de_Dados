/*
Script de implantação para Ecommerce

Este código foi gerado por uma ferramenta.
As alterações feitas nesse arquivo poderão causar comportamento incorreto e serão perdidas se
o código for gerado novamente.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "Ecommerce"
:setvar DefaultFilePrefix "Ecommerce"
:setvar DefaultDataPath "C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\"
:setvar DefaultLogPath "C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\"

GO
:on error exit
GO
/*
Detecta o modo SQLCMD e desabilita a execução do script se o modo SQLCMD não tiver suporte.
Para reabilitar o script após habilitar o modo SQLCMD, execute o comando a seguir:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'O modo SQLCMD deve ser habilitado para executar esse script com êxito.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
/*
Ignorando a coluna [dbo].[Dim_Clientes].[Aadditionals]; poderá ocorrer perda de dados.

Ignorando a coluna [dbo].[Dim_Clientes].[Create-at]; poderá ocorrer perda de dados.

Ignorando a coluna [dbo].[Dim_Clientes].[Nnumber]; poderá ocorrer perda de dados.

Ignorando a coluna [dbo].[Dim_Clientes].[Sstreet]; poderá ocorrer perda de dados.
*/

IF EXISTS (select top 1 1 from [dbo].[Dim_Clientes])
    RAISERROR (N'Linhas foram detectadas. A atualização de esquema está sendo encerrada porque pode ocorrer perda de dados.', 16, 127) WITH NOWAIT

GO
/*
Ignorando a coluna [dbo].[Fact_ordens].[create-at]; poderá ocorrer perda de dados.
*/

IF EXISTS (select top 1 1 from [dbo].[Fact_Ordens])
    RAISERROR (N'Linhas foram detectadas. A atualização de esquema está sendo encerrada porque pode ocorrer perda de dados.', 16, 127) WITH NOWAIT

GO
PRINT N'Iniciando a recompilação da tabela [dbo].[Dim_Clientes]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_Dim_Clientes] (
    [Id]          NVARCHAR (50)  NOT NULL,
    [Created_at]  DATETIME       NULL,
    [First_Name]  NVARCHAR (255) NULL,
    [Last_Name]   NVARCHAR (255) NULL,
    [Email]       NVARCHAR (255) NULL,
    [Cell_Phone]  NVARCHAR (50)  NULL,
    [Country]     NVARCHAR (255) NULL,
    [State]       NVARCHAR (255) NULL,
    [Street]      NVARCHAR (255) NULL,
    [Number]      NVARCHAR (50)  NULL,
    [Additionals] NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[Dim_Clientes])
    BEGIN
        INSERT INTO [dbo].[tmp_ms_xx_Dim_Clientes] ([Id], [First_name], [Last_name], [Email], [cell_phone], [Country], [State])
        SELECT   [Id],
                 [First_name],
                 [Last_name],
                 [Email],
                 [cell_phone],
                 [Country],
                 [State]
        FROM     [dbo].[Dim_Clientes]
        ORDER BY [Id] ASC;
    END

DROP TABLE [dbo].[Dim_Clientes];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_Dim_Clientes]', N'Dim_Clientes';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Iniciando a recompilação da tabela [dbo].[Fact_Ordens]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_Fact_Ordens] (
    [Id]          NVARCHAR (50)  NOT NULL,
    [created_at]  DATETIME       NULL,
    [customer_id] NVARCHAR (50)  NULL,
    [status]      NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[Fact_ordens])
    BEGIN
        INSERT INTO [dbo].[tmp_ms_xx_Fact_Ordens] ([Id], [status])
        SELECT   [Id],
                 [status]
        FROM     [dbo].[Fact_ordens]
        ORDER BY [Id] ASC;
    END

DROP TABLE [dbo].[Fact_ordens];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_Fact_Ordens]', N'Fact_Ordens';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Criando Tabela [dbo].[Dim_Produto]...';


GO
CREATE TABLE [dbo].[Dim_Produto] (
    [Id]          NVARCHAR (50)  NOT NULL,
    [Name]        NVARCHAR (200) NULL,
    [Price]       MONEY          NULL,
    [Id_Category] NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Criando Chave Estrangeira [dbo].[FK_Fact_Ordens_Dim_Clientes]...';


GO
ALTER TABLE [dbo].[Fact_Ordens] WITH NOCHECK
    ADD CONSTRAINT [FK_Fact_Ordens_Dim_Clientes] FOREIGN KEY ([Id]) REFERENCES [dbo].[Dim_Clientes] ([Id]);


GO
PRINT N'Criando Chave Estrangeira [dbo].[FK_Dim_Produto_Dim_Categoria]...';


GO
ALTER TABLE [dbo].[Dim_Produto] WITH NOCHECK
    ADD CONSTRAINT [FK_Dim_Produto_Dim_Categoria] FOREIGN KEY ([Id_Category]) REFERENCES [dbo].[Dim_Categoria] ([Id]);


GO
PRINT N'Criando Chave Estrangeira [dbo].[FK_Dim_Itens_Dim_Produto]...';


GO
ALTER TABLE [dbo].[Dim_Itens] WITH NOCHECK
    ADD CONSTRAINT [FK_Dim_Itens_Dim_Produto] FOREIGN KEY ([Id]) REFERENCES [dbo].[Dim_Produto] ([Id]);


GO
PRINT N'Criando Chave Estrangeira [dbo].[FK_Dim_Itens_Fact_Ordens]...';


GO
ALTER TABLE [dbo].[Dim_Itens] WITH NOCHECK
    ADD CONSTRAINT [FK_Dim_Itens_Fact_Ordens] FOREIGN KEY ([Id]) REFERENCES [dbo].[Fact_Ordens] ([Id]);


GO
PRINT N'Verificando os dados existentes em restrições recém-criadas';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dbo].[Fact_Ordens] WITH CHECK CHECK CONSTRAINT [FK_Fact_Ordens_Dim_Clientes];

ALTER TABLE [dbo].[Dim_Produto] WITH CHECK CHECK CONSTRAINT [FK_Dim_Produto_Dim_Categoria];

ALTER TABLE [dbo].[Dim_Itens] WITH CHECK CHECK CONSTRAINT [FK_Dim_Itens_Dim_Produto];

ALTER TABLE [dbo].[Dim_Itens] WITH CHECK CHECK CONSTRAINT [FK_Dim_Itens_Fact_Ordens];


GO
PRINT N'Atualização concluída.';


GO
