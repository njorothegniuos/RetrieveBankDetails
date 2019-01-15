USE [bankDetails]
GO
/****** Object:  Table [dbo].[ErrorLog]    Script Date: 1/15/2019 6:17:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
if exists(select name from sys.objects where name = N'ErrorLog')
    begin
        DROP TABLE [dbo].ErrorLog
    end
    go
CREATE TABLE [dbo].[ErrorLog](
	[IdxNo] [int] IDENTITY(1,1) NOT NULL,
	[ProgModule] [nvarchar](100) NOT NULL DEFAULT (''),
	[Source] [nvarchar](100) NOT NULL DEFAULT (''),
	[Terminal] [nvarchar](100) NOT NULL DEFAULT (''),
	[Officer] [nvarchar](100) NOT NULL DEFAULT (''),
	[ErrorDate] [datetime] NOT NULL DEFAULT (getdate()),
	[branchcode] [int] NOT NULL DEFAULT ((1000)),
	[Error] [varchar](8000) NOT NULL DEFAULT (''),
	[ErrorNumber] [int] NOT NULL DEFAULT ((0)),
	[ErrorSeverity] [int] NOT NULL DEFAULT ((0)),
	[ErrorState] [int] NOT NULL DEFAULT ((0)),
	[ErrorLine] [int] NOT NULL DEFAULT ((0)),
	[ErrorProcedure] [nvarchar](200) NOT NULL DEFAULT (''),
	[ErrorCreatedDate] [datetime] NULL CONSTRAINT [DF_ErrorLog_N_ErrorCreatedDate]  DEFAULT (getdate())
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

if exists(select name from sys.objects where name = N'SP_RethrowError')
    begin
        DROP PROCEDURE [dbo].SP_RethrowError
    end
    go
CREATE PROCEDURE [dbo].[SP_RethrowError] 
(@ProgModule AS VARCHAR(100),@Source AS VARCHAR(100),@Terminal AS VARCHAR(100),@Officer AS VARCHAR(100),@brcode AS int) AS 
	-- Create the stored procedure to generate an error using
	-- RAISERROR. The original error information is used to
	-- construct the msg_str for RAISERROR.
   -- Return if there is no error information to retrieve.
	BEGIN    
		IF ERROR_NUMBER() IS NULL
			RETURN;
             
		DECLARE
			@ErrorMessage    NVARCHAR(4000),
			@ErrorNumber     INT,
			@ErrorSeverity   INT,
			@ErrorState      INT,
			@ErrorLine       INT,
			@ErrorProcedure  NVARCHAR(200);
            
		-- Assign variables to error-handling functions that
		-- capture information for RAISERROR.
		SELECT 
			@ErrorNumber = ERROR_NUMBER(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE(),
			@ErrorLine = ERROR_LINE(),
			@ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-'),
			@ErrorMessage = ERROR_MESSAGE();
		-- Build the message string that will contain original
		-- error information.
		--    SELECT @ErrorMessage = 
		--        N'Error %d, Level %d, State %d, Procedure %s, Line %d, ' + 
		--            'Message: '+ ERROR_MESSAGE();
             
		-- Raise an error: msg_str parameter of RAISERROR will contain
		-- the original error information.
		--
		SET @ProgModule = ISNULL(@ProgModule,'');
		SET @Source = ISNULL(@Source,'');
		SET @Terminal = ISNULL(@Terminal,'');
		SET @Officer = ISNULL(@Officer,'');
		SET @brcode = ISNULL(@brcode,'');
		SET @ErrorMessage = ISNULL(@ErrorMessage,'');
		SET @ErrorNumber = ISNULL(@ErrorNumber,0);
		SET @ErrorSeverity = ISNULL(@ErrorSeverity,0);
		SET @ErrorState = ISNULL(@ErrorState,0);
		SET @ErrorLine = ISNULL(@ErrorLine,0);
		SET @ErrorProcedure = ISNULL(@ErrorProcedure,'-');
          
		INSERT INTO [dbo].[ErrorLog]
			      ([ProgModule], [Source], [Terminal], [Officer], [branchcode], [Error], [ErrorNumber], [ErrorSeverity], [ErrorState], [ErrorLine], [ErrorProcedure],ErrorCreatedDate)
			 VALUES(@ProgModule,@Source, @Terminal, @Officer, @brcode,substring(@ErrorMessage,0,8000),@ErrorNumber,@ErrorSeverity,@ErrorState,@ErrorLine,@ErrorProcedure,getdate());
          
		--    RAISERROR
		--        (
		--        @ErrorMessage,
		--        @ErrorSeverity,
		--        1,
		--        @ErrorNumber,    -- parameter: original error number.
		--        @ErrorSeverity,  -- parameter: original error severity.
		--        @ErrorState,     -- parameter: original error state.
		--        @ErrorProcedure, -- parameter: original error procedure name.
		--        @ErrorLine       -- parameter: original error line number.
		--        );
	END
GO


/****** Object:  StoredProcedure [dbo].[sp_InsertBankDetails]    Script Date: 1/15/2019 5:56:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,sam>
-- Create date: <Create Date,15/01/2018>
-- Description:	<Description,,stored procedure to insert bank details into table bank>
-- =============================================
if exists(select name from sys.objects where name = N'sp_InsertBankDetails')
    begin
        DROP PROCEDURE [dbo].sp_InsertBankDetails
    end
    go
create PROCEDURE [dbo].[sp_InsertBankDetails] 
	@bankname varchar(20),
	@BICNumber varchar(20),
	@City varchar(20),
	@ZipCode varchar(20)
AS
BEGIN
     SET NOCOUNT ON;
	Declare 
			@RespStat int = 0,
			@RespMsg varchar(150) = '';

      BEGIN TRY
	     	--- Validate
			if(@bankname is null or @bankname='')
			   Begin
				   Set @RespStat=1;
				   Set @RespMsg='Bank name is required!';
				   Select	@RespStat as RespStatus, @RespMsg as RespMessage;
				   return;
			   End
			 if(@BICNumber is null or @BICNumber='')
			   Begin
				   Set @RespStat=1;
				   Set @RespMsg='BIC Number is required!';
				   Select	@RespStat as RespStatus, @RespMsg as RespMessage;
				   return;
			   End
            if(@City is null or @City='')
			   Begin
				   Set @RespStat=1;
				   Set @RespMsg='City is required!';
				   Select	@RespStat as RespStatus, @RespMsg as RespMessage;
				   return;
			   End
			if(@ZipCode is null or @ZipCode='')
			   Begin
				   Set @RespStat=1;
				   Set @RespMsg='ZipCode is required!';
				   Select	@RespStat as RespStatus, @RespMsg as RespMessage;
				   return;
			   End
			
			    --insert data
				insert into bank(bankname,BICNumber,City,ZipCode)
				values(@bankname,@BICNumber,@City,@ZipCode);

				--create response
				 Set @RespStat=0;
				   Set @RespMsg='inserted data successfully';

				  Select	@RespStat as RespStatus, @RespMsg as RespMessage;

     END TRY
	BEGIN CATCH
		----- Create a response ---log  error in errorlog table
		 PRINT ''
		    PRINT 'Error ' + error_message();
			Select  2 as RespStatus, 'Error(s) Occurred' as RespMessage
			EXEC dbo.SP_RethrowError 'Retrieve BankDetails','sp_InsertBankDetails', 'BankDetails', 100,'00';	
		Select	@RespStat as RespStatus, @RespMsg as RespMessage
	END CATCH
END
Go

