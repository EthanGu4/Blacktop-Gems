module TeamsHelper
  TEAM_LOGOS = {
    "ATL" => "teams/ATL.svg",
    "BOS" => "teams/BOS.svg",
    "BKN" => "teams/BKN.svg",
    "CHA" => "teams/CHA.svg",
    "CHI" => "teams/CHI.svg",
    "CLE" => "teams/CLE.svg",
    "DAL" => "teams/DAL.svg",
    "DEN" => "teams/DEN.svg",
    "DET" => "teams/DET.svg",
    "GSW" => "teams/GSW.svg",
    "HOU" => "teams/HOU.svg",
    "IND" => "teams/IND.svg",
    "LAC" => "teams/LAC.svg",
    "LAL" => "teams/LAL.svg",
    "MEM" => "teams/MEM.svg",
    "MIA" => "teams/MIA.svg",
    "MIL" => "teams/MIL.svg",
    "MIN" => "teams/MIN.svg",
    "NOP" => "teams/NOP.svg",
    "NYK" => "teams/NYK.svg",
    "OKC" => "teams/OKC.svg",
    "ORL" => "teams/ORL.svg",
    "PHI" => "teams/PHI.svg",
    "PHX" => "teams/PHX.svg",
    "POR" => "teams/POR.svg",
    "SAC" => "teams/SAC.svg",
    "SAS" => "teams/SAS.svg",
    "TOR" => "teams/TOR.svg",
    "UTA" => "teams/UTA.svg",
    "WAS" => "teams/WAS.svg"
  }.freeze

  def team_logo_path(abbr)
    TEAM_LOGOS[abbr.to_s.upcase]
  end
end
