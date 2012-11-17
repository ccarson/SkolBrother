ALTER DATABASE [$(DatabaseName)]
    ADD LOG FILE (NAME = [mcfoodshield_log], FILENAME = '$(DefaultLogPath)$(DatabaseName).ldf', FILEGROWTH = 10 %);

