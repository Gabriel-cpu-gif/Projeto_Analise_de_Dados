CREATE TABLE [dbo].[Dim_Itens]
(
	[Id] NVARCHAR(50) NOT NULL PRIMARY KEY, 
    [Order_id] NVARCHAR(50) NULL, 
    [Product_id] NVARCHAR(50) NULL, 
    [Quantity] INT NULL, 
    [Total_Price] MONEY NULL, 
    CONSTRAINT [FK_Dim_Itens_Fact_Ordens] FOREIGN KEY (id) REFERENCES [Fact_Ordens] ([id]), 
    CONSTRAINT [FK_Dim_Itens_Dim_Produto] FOREIGN KEY (id) REFERENCES [Dim_Produto] ([id])
    
)
