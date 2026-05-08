-- =====================================================
-- Migration: Inserir 32 matches placeholder do mata-mata FIFA 2026
-- =====================================================
-- (R32: 73-88, R16: 89-96, QF: 97-100, SF: 101-102, 3º: 103, Final: 104)
--
-- IMPORTANTE: home_team_id/away_team_id ficam NULL inicialmente.
-- Backend /api/bracket faz UPDATE conforme top-2 dos grupos e vencedores
-- das fases anteriores são determinados (cascade).
--
-- Idempotente: skip se já existem matches com stage='round_of_32'.
-- =====================================================

IF NOT EXISTS (SELECT 1 FROM dbo.matches WHERE stage = 'round_of_32')
BEGIN
  DECLARE @stadium INT = (SELECT TOP 1 id FROM dbo.stadiums WHERE name LIKE '%MetLife%');
  IF @stadium IS NULL SET @stadium = (SELECT TOP 1 id FROM dbo.stadiums ORDER BY id);

  -- R32 (16 matches: 73-88)
  INSERT INTO dbo.matches (home_team_id, away_team_id, stadium_id, date, time, stage, group_name, status)
  VALUES
    (NULL, NULL, @stadium, '2026-07-01', '13:00', 'round_of_32', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-01', '17:00', 'round_of_32', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-01', '21:00', 'round_of_32', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-02', '13:00', 'round_of_32', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-02', '17:00', 'round_of_32', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-02', '21:00', 'round_of_32', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-03', '13:00', 'round_of_32', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-03', '17:00', 'round_of_32', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-03', '21:00', 'round_of_32', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-04', '13:00', 'round_of_32', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-04', '17:00', 'round_of_32', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-04', '21:00', 'round_of_32', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-05', '13:00', 'round_of_32', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-05', '17:00', 'round_of_32', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-05', '21:00', 'round_of_32', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-06', '17:00', 'round_of_32', NULL, 'scheduled');

  -- R16 (8 matches: 89-96)
  INSERT INTO dbo.matches (home_team_id, away_team_id, stadium_id, date, time, stage, group_name, status)
  VALUES
    (NULL, NULL, @stadium, '2026-07-08', '13:00', 'round_of_16', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-08', '17:00', 'round_of_16', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-08', '21:00', 'round_of_16', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-09', '13:00', 'round_of_16', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-09', '17:00', 'round_of_16', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-09', '21:00', 'round_of_16', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-10', '17:00', 'round_of_16', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-10', '21:00', 'round_of_16', NULL, 'scheduled');

  -- QF (4 matches: 97-100)
  INSERT INTO dbo.matches (home_team_id, away_team_id, stadium_id, date, time, stage, group_name, status)
  VALUES
    (NULL, NULL, @stadium, '2026-07-12', '17:00', 'quarter_final', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-12', '21:00', 'quarter_final', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-13', '17:00', 'quarter_final', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-13', '21:00', 'quarter_final', NULL, 'scheduled');

  -- SF (2 matches: 101-102)
  INSERT INTO dbo.matches (home_team_id, away_team_id, stadium_id, date, time, stage, group_name, status)
  VALUES
    (NULL, NULL, @stadium, '2026-07-15', '21:00', 'semi_final', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-16', '21:00', 'semi_final', NULL, 'scheduled');

  -- 3º/4º + Final
  INSERT INTO dbo.matches (home_team_id, away_team_id, stadium_id, date, time, stage, group_name, status)
  VALUES
    (NULL, NULL, @stadium, '2026-07-18', '17:00', 'third_place', NULL, 'scheduled'),
    (NULL, NULL, @stadium, '2026-07-19', '16:00', 'final', NULL, 'scheduled');
END
GO

-- Validação
SELECT stage, COUNT(*) AS n
FROM dbo.matches
WHERE stage IN ('round_of_32','round_of_16','quarter_final','semi_final','third_place','final')
GROUP BY stage
ORDER BY
  CASE stage
    WHEN 'round_of_32' THEN 1
    WHEN 'round_of_16' THEN 2
    WHEN 'quarter_final' THEN 3
    WHEN 'semi_final' THEN 4
    WHEN 'third_place' THEN 5
    WHEN 'final' THEN 6
  END;
GO

PRINT 'Migration concluida. Total esperado: R32=16, R16=8, QF=4, SF=2, 3rd=1, Final=1.';
GO
