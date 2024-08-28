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
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULLS ON,
                ANSI_PADDING ON,
                ANSI_WARNINGS ON,
                ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                QUOTED_IDENTIFIER ON,
                ANSI_NULL_DEFAULT ON,
                CURSOR_DEFAULT LOCAL 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET PAGE_VERIFY NONE 
            WITH ROLLBACK IMMEDIATE;
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET TARGET_RECOVERY_TIME = 0 SECONDS 
    WITH ROLLBACK IMMEDIATE;


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE (QUERY_CAPTURE_MODE = ALL, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 367), MAX_STORAGE_SIZE_MB = 100) 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE = OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
PRINT N'A operação de refatoração Renomear com chave a5f2d23f-2be6-4f4d-bf65-c0bdf2665d86 foi ignorada; o elemento [dbo].[Dim_ Produto].[pRICE] (SqlSimpleColumn) não será renomeado para Price';


GO
PRINT N'Criando Tabela [dbo].[Dim_Categoria]...';


GO
CREATE TABLE [dbo].[Dim_Categoria] (
    [Id]   NVARCHAR (50)  NOT NULL,
    [name] NVARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Criando Tabela [dbo].[Dim_Clientes]...';


GO
CREATE TABLE [dbo].[Dim_Clientes] (
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


GO
PRINT N'Criando Tabela [dbo].[Dim_Itens]...';


GO
CREATE TABLE [dbo].[Dim_Itens] (
    [Id]          NVARCHAR (50) NOT NULL,
    [Order_id]    NVARCHAR (50) NULL,
    [Product_id]  NVARCHAR (50) NULL,
    [Quantity]    INT           NULL,
    [Total_Price] MONEY         NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


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
PRINT N'Criando Tabela [dbo].[Fact_Ordens]...';


GO
CREATE TABLE [dbo].[Fact_Ordens] (
    [Id]          NVARCHAR (50)  NOT NULL,
    [created_at]  DATETIME       NULL,
    [customer_id] NVARCHAR (50)  NULL,
    [status]      NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Criando Chave Estrangeira [dbo].[FK_Dim_Itens_Fact_Ordens]...';


GO
ALTER TABLE [dbo].[Dim_Itens] WITH NOCHECK
    ADD CONSTRAINT [FK_Dim_Itens_Fact_Ordens] FOREIGN KEY ([Id]) REFERENCES [dbo].[Fact_Ordens] ([Id]);


GO
PRINT N'Criando Chave Estrangeira [dbo].[FK_Dim_Itens_Dim_Produto]...';


GO
ALTER TABLE [dbo].[Dim_Itens] WITH NOCHECK
    ADD CONSTRAINT [FK_Dim_Itens_Dim_Produto] FOREIGN KEY ([Id]) REFERENCES [dbo].[Dim_Produto] ([Id]);


GO
PRINT N'Criando Chave Estrangeira [dbo].[FK_Dim_Produto_Dim_Categoria]...';


GO
ALTER TABLE [dbo].[Dim_Produto] WITH NOCHECK
    ADD CONSTRAINT [FK_Dim_Produto_Dim_Categoria] FOREIGN KEY ([Id_Category]) REFERENCES [dbo].[Dim_Categoria] ([Id]);


GO
PRINT N'Criando Chave Estrangeira [dbo].[FK_Fact_Ordens_Dim_Clientes]...';


GO
ALTER TABLE [dbo].[Fact_Ordens] WITH NOCHECK
    ADD CONSTRAINT [FK_Fact_Ordens_Dim_Clientes] FOREIGN KEY ([Id]) REFERENCES [dbo].[Dim_Clientes] ([Id]);


GO
-- Etapa de refatoração para atualizar o servidor de destino com logs de transação implantados

IF OBJECT_ID(N'dbo.__RefactorLog') IS NULL
BEGIN
    CREATE TABLE [dbo].[__RefactorLog] (OperationKey UNIQUEIDENTIFIER NOT NULL PRIMARY KEY)
    EXEC sp_addextendedproperty N'microsoft_database_tools_support', N'refactoring log', N'schema', N'dbo', N'table', N'__RefactorLog'
END
GO
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = 'a5f2d23f-2be6-4f4d-bf65-c0bdf2665d86')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('a5f2d23f-2be6-4f4d-bf65-c0bdf2665d86')

GO

GO
PRINT N'Verificando os dados existentes em restrições recém-criadas';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dbo].[Dim_Itens] WITH CHECK CHECK CONSTRAINT [FK_Dim_Itens_Fact_Ordens];

ALTER TABLE [dbo].[Dim_Itens] WITH CHECK CHECK CONSTRAINT [FK_Dim_Itens_Dim_Produto];

ALTER TABLE [dbo].[Dim_Produto] WITH CHECK CHECK CONSTRAINT [FK_Dim_Produto_Dim_Categoria];

ALTER TABLE [dbo].[Fact_Ordens] WITH CHECK CHECK CONSTRAINT [FK_Fact_Ordens_Dim_Clientes];


GO
PRINT N'Atualização concluída.';


GO
