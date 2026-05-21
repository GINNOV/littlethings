(*
Copyright (c) 1994 - 2000 Marc Necker.

This file is part of Analay (v2.0).
http://www.analay.de

Analay is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License version 2
as published by the Free Software Foundation.

Analay is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Analay.  If not, see <https://www.gnu.org/licenses/>.
*)


MODULE AnalayCatalog;

IMPORT lo : Locale,
       e  : Exec,
       u  : Utility,
       y  : SYSTEM;

CONST builtinlanguage = "english";
      version = 0;

      GuideName * = 0;
      GuideNameSTR = "AnalayEnglish.guide";
      OK * = 1;
      OKSTR = "OK";
      Cancel * = 2;
      CancelSTR = "Cancel";
      Yes * = 3;
      YesSTR = "Yes";
      No * = 4;
      NoSTR = "No";
      Help * = 5;
      HelpSTR = "Help";
      None * = 6;
      NoneSTR = "No";
      Program * = 7;
      ProgramSTR = "Program";
      Load * = 8;
      LoadSTR = "Load";
      Save * = 9;
      SaveSTR = "Save";
      SaveAs * = 10;
      SaveAsSTR = "Save as";
      Layout * = 11;
      LayoutSTR = "Layout";
      About * = 12;
      AboutSTR = "About";
      Quit * = 13;
      QuitSTR = "Quit";
      Function * = 14;
      FunctionSTR = "Function";
      Input * = 15;
      InputSTR = "Input";
      DefinitionDomain * = 16;
      DefinitionDomainSTR = "Domain";
      Connect * = 17;
      ConnectSTR = "Connect";
      Process * = 18;
      ProcessSTR = "Process";
      ChangeConstants * = 19;
      ChangeConstantsSTR = "Change constants";
      QuickEnter * = 20;
      QuickEnterSTR = "Quick input";
      Windows * = 21;
      WindowsSTR = "Windows";
      Create * = 22;
      CreateSTR = "Create";
      Settings * = 23;
      SettingsSTR = "Settings";
      AxisLimits * = 24;
      AxisLimitsSTR = "Axis limits";
      AxisDesign * = 25;
      AxisDesignSTR = "Axis design";
      Grid * = 26;
      GridSTR = "Grid";
      GraphDesign * = 27;
      GraphDesignSTR = "Graph design";
      Text * = 28;
      TextSTR = "Text";
      Place * = 29;
      PlaceSTR = "Place";
      Change * = 30;
      ChangeSTR = "Change";
      Delete * = 31;
      DeleteSTR = "Delete";
      Default * = 32;
      DefaultSTR = "Default";
      Point * = 33;
      PointSTR = "Point";
      Marker * = 34;
      MarkerSTR = "Marker";
      Hatching * = 35;
      HatchingSTR = "Hatching";
      Analysis * = 36;
      AnalysisSTR = "Analysis";
      FindZeros * = 37;
      FindZerosSTR = "Find zeros";
      FindExtremes * = 38;
      FindExtremesSTR = "Find extremes";
      FindGaps * = 39;
      FindGapsSTR = "Find gaps";
      FindInflections * = 40;
      FindInflectionsSTR = "Find points of inflection";
      FindIntersections * = 41;
      FindIntersectionsSTR = "Find intersections";
      CompleteAnalysis * = 42;
      CompleteAnalysisSTR = "Complete analysis";
      CompleteSettings * = 43;
      CompleteSettingsSTR = "Compl. analysis settings";
      CompleteAnalysisSettings * = 44;
      CompleteAnalysisSettingsSTR = "Complete analysis settings";
      CalcArea * = 45;
      CalcAreaSTR = "Calculate area";
      Special * = 46;
      SpecialSTR = "Special";
      Legend * = 47;
      LegendSTR = "Legend";
      Table * = 48;
      TableSTR = "Table";
      List * = 49;
      ListSTR = "List";
      SettingsMenu * = 50;
      SettingsMenuSTR = "Settings";
      ScreenModeMenu * = 51;
      ScreenModeMenuSTR = "Screen mode";
      ScreenColors * = 52;
      ScreenColorsSTR = "Palette";
      Priorities * = 53;
      PrioritiesSTR = "Priorities";
      UseWBScreen * = 54;
      UseWBScreenSTR = "Use Workbench Screen";
      QuickSelect * = 55;
      QuickSelectSTR = "Quick-select";
      AutoActiveWindow * = 56;
      AutoActiveWindowSTR = "Auto active window";
      CloneWB * = 57;
      CloneWBSTR = "Clone Workbench";
      DerivativeOf * = 58;
      DerivativeOfSTR = "Derivative of";
      Name * = 59;
      NameSTR = "Name";
      Symbol * = 60;
      SymbolSTR = "Symbol";
      Comment * = 61;
      CommentSTR = "Comment";
      Value * = 62;
      ValueSTR = "Value";
      ChangeConstantsReq * = 63;
      ChangeConstantsReqSTR = "Change constants";
      InternalConstants * = 64;
      InternalConstantsSTR = "Internal constants";
      TemporaryConstants * = 65;
      TemporaryConstantsSTR = "Temporary constants";
      NewConstant * = 66;
      NewConstantSTR = "New constant";
      DelConstant * = 67;
      DelConstantSTR = "Delete constant";
      CopyConstant * = 68;
      CopyConstantSTR = "Copy constant";
      ConstantsEx * = 69;
      ConstantsExSTR = "constants!";
      Constant * = 70;
      ConstantSTR = "Constant";
      ConstantsMustNot * = 71;
      ConstantsMustNotSTR = "A constant cannot";
      DependOnItself * = 72;
      DependOnItselfSTR = "define itself!";
      SetScreenColors * = 73;
      SetScreenColorsSTR = "Palette";
      Color * = 74;
      ColorSTR = "Color";
      Colors * = 75;
      ColorsSTR = "Colors";
      RedDP * = 76;
      RedDPSTR = "Red:";
      GreenDP * = 77;
      GreenDPSTR = "Green:";
      BlueDP * = 78;
      BlueDPSTR = "Blue:";
      ReservedDP * = 79;
      ReservedDPSTR = "Reserved:";
      EnterPoint * = 80;
      EnterPointSTR = "Enter point";
      PointCoordinates * = 81;
      PointCoordinatesSTR = "Coordinates of point";
      XCoord * = 82;
      XCoordSTR = "x-coord";
      YCoord * = 83;
      YCoordSTR = "y-coord";
      ReflectFunction * = 84;
      ReflectFunctionSTR = "Reflection";
      ThroughLineX * = 85;
      ThroughLineXSTR = "through line x=";
      ThroughLineY * = 86;
      ThroughLineYSTR = "through line y=";
      ThroughPoint * = 87;
      ThroughPointSTR = "through point";
      EnterFunctions * = 88;
      EnterFunctionsSTR = "Enter functions";
      NewFunction * = 89;
      NewFunctionSTR = "New function";
      DelFunction * = 90;
      DelFunctionSTR = "Delete function";
      CopyFunction * = 91;
      CopyFunctionSTR = "Copy function";
      AppendFunction * = 92;
      AppendFunctionSTR = "Append function";
      DeriveFunction * = 93;
      DeriveFunctionSTR = "Derivative of function";
      NewVariable * = 94;
      NewVariableSTR = "New variable";
      DelVariable * = 95;
      DelVariableSTR = "Delete variable";
      CopyVariable * = 96;
      CopyVariableSTR = "Copy variable";
      Functions * = 97;
      FunctionsSTR = "Functions";
      Variables * = 98;
      VariablesSTR = "Variables";
      FunctionsEx * = 99;
      FunctionsExSTR = "functions!";
      VariablesEx * = 100;
      VariablesExSTR = "variables!";
      ErrorInVariableInput * = 101;
      ErrorInVariableInputSTR = "Error in variable input:";
      VariableNameMissing * = 102;
      VariableNameMissingSTR = "Variable name missing!";
      LowerLimitMissing * = 103;
      LowerLimitMissingSTR = "Lower limit missing!";
      UpperLimitMissing * = 104;
      UpperLimitMissingSTR = "Upper limit missing!";
      WarningDP * = 105;
      WarningDPSTR = "Warning:";
      bracketsNotClosed * = 106;
      bracketsNotClosedSTR = "bracket(s) not closed!";
      TooManyBracketsClosed * = 107;
      TooManyBracketsClosedSTR = "Too many brackets closed!";
      ErrorInFunctionInput * = 108;
      ErrorInFunctionInputSTR = "Error in function input:";
      IllegalUseOfMathematicalSign * = 109;
      IllegalUseOfMathematicalSignSTR = "Illegal use of mathematical sign!";
      ErrorInNumberFormat * = 110;
      ErrorInNumberFormatSTR = "Error in number format!";
      OpeningBracketExpected * = 111;
      OpeningBracketExpectedSTR = "'(' expected!";
      MathematicalSignExpected * = 112;
      MathematicalSignExpectedSTR = "Mathematical sign expected!";
      OperandExpected * = 113;
      OperandExpectedSTR = "Operand expected!";
      ProcessFunctions * = 114;
      ProcessFunctionsSTR = "Process functions";
      TangentAtPoint * = 115;
      TangentAtPointSTR = "Tangent at point P";
      NormalAtPoint * = 116;
      NormalAtPointSTR = "Normal at point P";
      Derivative * = 117;
      DerivativeSTR = "Derivative";
      DeriveFor * = 118;
      DeriveForSTR = "With respect to";
      TangentCannotBe * = 119;
      TangentCannotBeSTR = "Tangent cannot be";
      DrawnAtAGapTangent * = 120;
      DrawnAtAGapTangentSTR = "drawn at a gap!";
      NormalCannotBe * = 121;
      NormalCannotBeSTR = "Normal cannot be";
      DrawnAtAGapNormal * = 122;
      DrawnAtAGapNormalSTR = "drawn at a gap!";
      ReflectionOf * = 123;
      ReflectionOfSTR = "Reflection of";
      EnterFunction * = 124;
      EnterFunctionSTR = "Enter function";
      Auto * = 125;
      AutoSTR = "Auto";
      CreateWindows * = 126;
      CreateWindowsSTR = "Create windows";
      NoWindow * = 127;
      NoWindowSTR = "No window";
      SelectedEx * = 128;
      SelectedExSTR = "selected!";
      NewWindow * = 129;
      NewWindowSTR = "New window";
      DelWindow * = 130;
      DelWindowSTR = "Delete window";
      CopyWindow * = 131;
      CopyWindowSTR = "Copy window";
      AppendWindow * = 132;
      AppendWindowSTR = "Append window";
      InsertFunction * = 133;
      InsertFunctionSTR = "Insert function";
      DelFunctionCreateWindows * = 134;
      DelFunctionCreateWindowsSTR = "Delete function";
      WindowsEx * = 135;
      WindowsExSTR = "windows!";
      Window * = 136;
      WindowSTR = "Window";
      WindowDP * = 137;
      WindowDPSTR = "Window:";
      SelectedFunctions * = 138;
      SelectedFunctionsSTR = "Selected functions";
      AvailableFunctions * = 139;
      AvailableFunctionsSTR = "Available functions";
      ChangeUserDomain * = 140;
      ChangeUserDomainSTR = "Change user-domain";
      NewDomain * = 141;
      NewDomainSTR = "New domain";
      DelDomain * = 142;
      DelDomainSTR = "Delete domain";
      CopyDomain * = 143;
      CopyDomainSTR = "Copy domain";
      UserDefinitionDomain * = 144;
      UserDefinitionDomainSTR = "User-defined domain";
      DefinedAt * = 145;
      DefinedAtSTR = "Defined at";
      AllX * = 146;
      AllXSTR = "all x";
      ErrorInDomainInput * = 147;
      ErrorInDomainInputSTR = "Error in domain input:";
      SymbolsMissing * = 148;
      SymbolsMissingSTR = "< or > missing!";
      DomainMustContainAtLeast * = 149;
      DomainMustContainAtLeastSTR = "Domain must contain";
      TwoLimits * = 150;
      TwoLimitsSTR = "two limits!";
      MissingFourth * = 151;
      MissingFourthSTR = "Fourth parameter missing!";
      ConnectFunctions * = 152;
      ConnectFunctionsSTR = "Connect functions";
      NewConnection * = 153;
      NewConnectionSTR = "New connection";
      DelConnection * = 154;
      DelConnectionSTR = "Delete connection";
      CopyConnection * = 155;
      CopyConnectionSTR = "Copy connection";
      NoConnection * = 156;
      NoConnectionSTR = "No connection";
      Connections * = 157;
      ConnectionsSTR = "Connections";
      ConnectionsEx * = 158;
      ConnectionsExSTR = "connections!";
      Connection * = 159;
      ConnectionSTR = "Connection";
      ConnectedFunctions * = 160;
      ConnectedFunctionsSTR = "Connected functions";
      Grid1On * = 161;
      Grid1OnSTR = "Grid 1 active";
      Grid2On * = 162;
      Grid2OnSTR = "Grid 2 active";
      GridDesign * = 163;
      GridDesignSTR = "Grid design";
      GridSize * = 164;
      GridSizeSTR = "Interval";
      StartCoordinates * = 165;
      StartCoordinatesSTR = "Starting coordinates";
      LinePattern * = 166;
      LinePatternSTR = "Line pattern";
      LineThickness * = 167;
      LineThicknessSTR = "Line thickness";
      Font * = 168;
      FontSTR = "Font";
      AxisSystemOn * = 169;
      AxisSystemOnSTR = "Axis system on";
      AxisRealDesign * = 170;
      AxisRealDesignSTR = "Axis design";
      Scale * = 171;
      ScaleSTR = "Scale";
      Values * = 172;
      ValuesSTR = "Values";
      Ticks1 * = 173;
      Ticks1STR = "Ticks 1";
      Ticks2 * = 174;
      Ticks2STR = "Ticks 2";
      XAxisLabel * = 175;
      XAxisLabelSTR = "x-axis label";
      YAxisLabel * = 176;
      YAxisLabelSTR = "y-axis label";
      Arrow * = 177;
      ArrowSTR = "Arrow";
      SelectAxisLabelsFont * = 178;
      SelectAxisLabelsFontSTR = "Font for axis labels";
      ChangeAxisLimits * = 179;
      ChangeAxisLimitsSTR = "Change axis limits";
      CartesianAxisLimits * = 180;
      CartesianAxisLimitsSTR = "Axis limits";
      UndoChanges * = 181;
      UndoChangesSTR = "Undo changes";
      ScreenMode * = 182;
      ScreenModeSTR = "Screen mode";
      Width * = 183;
      WidthSTR = "Width";
      Height * = 184;
      HeightSTR = "Height";
      Interlace * = 185;
      InterlaceSTR = "Interlace";
      NTSC * = 186;
      NTSCSTR = "NTSC";
      NoResolutions * = 187;
      NoResolutionsSTR = "No resolutions";
      FoundEx * = 188;
      FoundExSTR = "found!";
      ScreenResolution * = 189;
      ScreenResolutionSTR = "Screen resolution";
      FunctionDesign * = 190;
      FunctionDesignSTR = "Function design";
      FunctionFamily * = 191;
      FunctionFamilySTR = "function family";
      Design * = 192;
      DesignSTR = "Design";
      FunctionFamilies * = 193;
      FunctionFamiliesSTR = "Function families";
      NoneFemSing * = 194;
      NoneFemSingSTR = "No";
      FamilyEx * = 195;
      FamilyExSTR = "family!";
      NumberFormat * = 196;
      NumberFormatSTR = "Number format";
      Exponent * = 197;
      ExponentSTR = "Exponent";
      DecimalPlaces * = 198;
      DecimalPlacesSTR = "Decimal places";
      WindowSettings * = 199;
      WindowSettingsSTR = "Window settings";
      FunctionDisplayed * = 200;
      FunctionDisplayedSTR = "function displayed";
      FunctionsDisplayed * = 201;
      FunctionsDisplayedSTR = "functions displayed";
      ModeDP * = 202;
      ModeDPSTR = "Mode:";
      Cartesian2D * = 203;
      Cartesian2DSTR = "2D cartesian";
      Transparent * = 204;
      TransparentSTR = "Transparent";
      BorderFree * = 205;
      BorderFreeSTR = "Border free";
      AutoYRange * = 206;
      AutoYRangeSTR = "Auto y-range";
      AutoAxisLabels * = 207;
      AutoAxisLabelsSTR = "Auto axis labels";
      AutoGrid * = 208;
      AutoGridSTR = "Auto-grid";
      BackgroundColor * = 209;
      BackgroundColorSTR = "Background color";
      ForegroundColor * = 210;
      ForegroundColorSTR = "Foreground color";
      NumberOfSegments * = 211;
      NumberOfSegmentsSTR = "Number of segments";
      ValueRange * = 212;
      ValueRangeSTR = "Range of values";
      Start * = 213;
      StartSTR = "Start";
      End * = 214;
      EndSTR = "End";
      Step * = 215;
      StepSTR = "Step";
      SetPriorities * = 216;
      SetPrioritiesSTR = "Set priorities";
      MathMode * = 217;
      MathModeSTR = "Math Mode";
      LayoutMode * = 218;
      LayoutModeSTR = "Layout Mode";
      MathRequesters * = 219;
      MathRequestersSTR = "Math Requesters";
      AfterWindow * = 220;
      AfterWindowSTR = "After window";
      DeleteListLegend * = 221;
      DeleteListLegendSTR = "Delete legend";
      AppendWindowLegend * = 222;
      AppendWindowLegendSTR = "Append window";
      InsertWindowLegend * = 223;
      InsertWindowLegendSTR = "Insert window";
      FunctionSymbol * = 224;
      FunctionSymbolSTR = "Function symbol";
      FamilySymbol * = 225;
      FamilySymbolSTR = "Family symbol";
      ChangeLegend * = 226;
      ChangeLegendSTR = "Change legend";
      AppendLine * = 227;
      AppendLineSTR = "Append line";
      InsertLine * = 228;
      InsertLineSTR = "Insert line";
      DeleteLine * = 229;
      DeleteLineSTR = "Delete line";
      LegendGeneral * = 230;
      LegendGeneralSTR = "Process legend";
      CurrentLine * = 231;
      CurrentLineSTR = "Current line";
      LegendPreview * = 232;
      LegendPreviewSTR = "Legend preview";
      FunctionsUniform * = 233;
      FunctionsUniformSTR = "Functions uniform";
      FamiliesUniform * = 234;
      FamiliesUniformSTR = "Families uniform";
      IndentFamilies * = 235;
      IndentFamiliesSTR = "Indent families";
      WindowModel * = 236;
      WindowModelSTR = "Window model";
      PointDesign * = 237;
      PointDesignSTR = "Point design";
      Family * = 238;
      FamilySTR = "Family";
      SelectWindow * = 239;
      SelectWindowSTR = "Select window";
      SelectLegend * = 240;
      SelectLegendSTR = "Select legend";
      SelectTable * = 241;
      SelectTableSTR = "Select table";
      SelectList * = 242;
      SelectListSTR = "Select list";
      SelectHatching * = 243;
      SelectHatchingSTR = "Select hatching";
      AtTheMomentNo * = 244;
      AtTheMomentNoSTR = "At the moment no";
      InThisWindowNo * = 245;
      InThisWindowNoSTR = "In this window no";
      WindowsAreDisplayed * = 246;
      WindowsAreDisplayedSTR = "windows are displayed!";
      LegendsAreDisplayed * = 247;
      LegendsAreDisplayedSTR = "legends are displayed!";
      TablesAreDisplayed * = 248;
      TablesAreDisplayedSTR = "tables are displayed!";
      ListsAreDisplayed * = 249;
      ListsAreDisplayedSTR = "lists are displayed!";
      FunctionsAreEntered * = 250;
      FunctionsAreEnteredSTR = "functions are entered!";
      TextsAreDisplayed * = 251;
      TextsAreDisplayedSTR = "texts are displayed!";
      PointsAreDisplayed * = 252;
      PointsAreDisplayedSTR = "points are displayed!";
      MarkersAreDisplayed * = 253;
      MarkersAreDisplayedSTR = "markers are displayed!";
      HatchingsAreDisplayed * = 254;
      HatchingsAreDisplayedSTR = "hatchings are displayed!";
      FunctionsAreDisplayed * = 255;
      FunctionsAreDisplayedSTR = "functions are displayed!";
      ChangeDesign * = 256;
      ChangeDesignSTR = "Change design";
      Preview * = 257;
      PreviewSTR = "Preview";
      HorizontalSeparation * = 258;
      HorizontalSeparationSTR = "Horizontal separation";
      VerticalSeparation * = 259;
      VerticalSeparationSTR = "Vertical separation";
      RowsEx * = 260;
      RowsExSTR = "rows!";
      ColumnsEx * = 261;
      ColumnsExSTR = "columns!";
      ChangeList * = 262;
      ChangeListSTR = "Change list";
      AddColumn * = 263;
      AddColumnSTR = "Add column";
      InsertColumn * = 264;
      InsertColumnSTR = "Insert column";
      DeleteColumn * = 265;
      DeleteColumnSTR = "Delete column";
      ListDesign * = 266;
      ListDesignSTR = "List design";
      AppendField * = 267;
      AppendFieldSTR = "Append field";
      InsertField * = 268;
      InsertFieldSTR = "Insert field";
      DeleteField * = 269;
      DeleteFieldSTR = "Delete field";
      CalcColumn * = 270;
      CalcColumnSTR = "Calculate column";
      SelectColumnWithXValues * = 271;
      SelectColumnWithXValuesSTR = " Select column";
      ListGeneral * = 272;
      ListGeneralSTR = "Process List";
      CurrentColumn * = 273;
      CurrentColumnSTR = "Current column";
      ListPreview * = 274;
      ListPreviewSTR = "List preview";
      ColumnWidthUniform * = 275;
      ColumnWidthUniformSTR = "Column-width uniform";
      CenterText * = 276;
      CenterTextSTR = "Center text";
      DecimalTabulator * = 277;
      DecimalTabulatorSTR = "Decimal tabulator";
      SeparateHeadline * = 278;
      SeparateHeadlineSTR = "Separate headline";
      NumberFieldsUniform * = 279;
      NumberFieldsUniformSTR = "Nº of fields uniform";
      Entries * = 280;
      EntriesSTR = "Entries";
      SelectFontForList * = 281;
      SelectFontForListSTR = "Select font for list";
      TheListMustContainAtLeast * = 282;
      TheListMustContainAtLeastSTR = "The list must contain at least";
      OneColumnForThisFunction * = 283;
      OneColumnForThisFunctionSTR = "1 column for this function!";
      TwoColumnsForThisFunction * = 284;
      TwoColumnsForThisFunctionSTR = "2 columns for this function!";
      SelectFunction * = 285;
      SelectFunctionSTR = "Select function";
      SelectFunction1 * = 286;
      SelectFunction1STR = "Select function 1";
      SelectFunction2 * = 287;
      SelectFunction2STR = "Select function 2";
      ChangeTable * = 288;
      ChangeTableSTR = "Change table";
      TableDesign * = 289;
      TableDesignSTR = "Table design";
      CalcRow * = 290;
      CalcRowSTR = "Calculate row";
      SelectRowWithXValues * = 291;
      SelectRowWithXValuesSTR = " Select row";
      TablePreview * = 292;
      TablePreviewSTR = "Table preview";
      ProcessTable * = 293;
      ProcessTableSTR = "Process table";
      ColumnWidthUniformShort * = 294;
      ColumnWidthUniformShortSTR = "Uniform col-width";
      SeparateFirstColumn * = 295;
      SeparateFirstColumnSTR = "Separate column 1";
      SelectFontForTable * = 296;
      SelectFontForTableSTR = "Select font for table";
      TheTableMustContainAtLeast * = 297;
      TheTableMustContainAtLeastSTR = "The table must contain at least";
      OneRowForThisFunction * = 298;
      OneRowForThisFunctionSTR = "1 row for this function!";
      TwoRowsForThisFunction * = 299;
      TwoRowsForThisFunctionSTR = "2 rows for this function!";
      ChangeText * = 300;
      ChangeTextSTR = "Change text";
      Mouse * = 301;
      MouseSTR = "Mouse";
      Coordinates * = 302;
      CoordinatesSTR = "Coordinates";
      Bold * = 303;
      BoldSTR = "Bold";
      Italic * = 304;
      ItalicSTR = "Italic";
      Underlined * = 305;
      UnderlinedSTR = "Underlined";
      SnapToGraph * = 306;
      SnapToGraphSTR = "Snap to graph";
      SelectFontForText * = 307;
      SelectFontForTextSTR = "Select font for text";
      ChangePoint * = 308;
      ChangePointSTR = "Change point";
      ChangeMarker * = 309;
      ChangeMarkerSTR = "Change marker";
      FillPoint * = 310;
      FillPointSTR = "Fill point";
      MarkerDesign * = 311;
      MarkerDesignSTR = "Marker design";
      MarkerLegend * = 312;
      MarkerLegendSTR = "Text arrangement";
      MarkerPattern * = 313;
      MarkerPatternSTR = "Line pattern";
      MarkerWidth * = 314;
      MarkerWidthSTR = "Line width";
      TextOrientation * = 315;
      TextOrientationSTR = "Orientation";
      TextSide * = 316;
      TextSideSTR = "Position";
      NewEntry * = 317;
      NewEntrySTR = "New entry";
      DelEntry * = 318;
      DelEntrySTR = "Delete entry";
      AxesCoordinates * = 319;
      AxesCoordinatesSTR = "Graph coordinates";
      ScreenCoordinates * = 320;
      ScreenCoordinatesSTR = "Screen coordinates";
      Pattern * = 321;
      PatternSTR = "Pattern";
      PatternsEx * = 322;
      PatternsExSTR = "patterns!";
      NewPattern * = 323;
      NewPatternSTR = "New pattern";
      DelPattern * = 324;
      DelPatternSTR = "Delete pattern";
      TextTransparent * = 325;
      TextTransparentSTR = "Text transparent";
      SelectFontForPoint * = 326;
      SelectFontForPointSTR = "Select font for label";
      Of * = 327;
      OfSTR = "of";
      CreatePoints * = 328;
      CreatePointsSTR = "Create points";
      NameOfFirstPoint * = 329;
      NameOfFirstPointSTR = "Name of point 1";
      CreateMarkers * = 330;
      CreateMarkersSTR = "Create markers";
      NameOfFirstMarker * = 331;
      NameOfFirstMarkerSTR = "Name of marker 1";
      OfFunctions * = 332;
      OfFunctionsSTR = "of functions";
      OfFunction * = 333;
      OfFunctionSTR = "of function";
      XAxisDomain * = 334;
      XAxisDomainSTR = "Domain";
      Abscissa * = 335;
      AbscissaSTR = "Abscissa";
      Ordinate * = 336;
      OrdinateSTR = "Ordinate";
      DefaultList * = 337;
      DefaultListSTR = "Default list style";
      CustomList * = 338;
      CustomListSTR = "Custom list style";
      DefaultPoint * = 339;
      DefaultPointSTR = "Default point style";
      CustomPoint * = 340;
      CustomPointSTR = "Custom point style";
      DefaultMarker * = 341;
      DefaultMarkerSTR = "Default marker style";
      CustomMarker * = 342;
      CustomMarkerSTR = "Custom marker style";
      AsList * = 343;
      AsListSTR = "As list";
      AsPoints * = 344;
      AsPointsSTR = "As points";
      AsMarkers * = 345;
      AsMarkersSTR = "As markers";
      ChangeVariable * = 346;
      ChangeVariableSTR = "Change variable";
      InThe * = 347;
      InTheSTR = "in the";
      Range * = 348;
      RangeSTR = "range";
      FindingMaximumPoints * = 349;
      FindingMaximumPointsSTR = "Finding maximum points";
      FindingMinimumPoints * = 350;
      FindingMinimumPointsSTR = "Finding minimum points";
      SetVariableValues * = 351;
      SetVariableValuesSTR = "Set variablevalues";
      Undefined * = 352;
      UndefinedSTR = "undefined";
      LocalMaximum * = 353;
      LocalMaximumSTR = "Local maximum";
      LocalMinimum * = 354;
      LocalMinimumSTR = "Local minimum";
      GlobalMaximumQ * = 355;
      GlobalMaximumQSTR = "Absolute(?) maximum";
      GlobalMinimumQ * = 356;
      GlobalMinimumQSTR = "Absolute(?) minimum";
      ExtremePoints * = 357;
      ExtremePointsSTR = "Extreme points";
      FindingZeros * = 358;
      FindingZerosSTR = "Finding zeros";
      ChangeInSign * = 359;
      ChangeInSignSTR = "Change in sign";
      NoChangeInSign * = 360;
      NoChangeInSignSTR = "No change in sign";
      Zeros * = 361;
      ZerosSTR = "Zeros";
      FindingGaps * = 362;
      FindingGapsSTR = "Finding gaps";
      DefinitionGaps * = 363;
      DefinitionGapsSTR = "Definition gaps";
      CurvatureLeftRight * = 364;
      CurvatureLeftRightSTR = "Curvature left-right";
      CurvatureRightLeft * = 365;
      CurvatureRightLeftSTR = "Curvature right-left";
      FindingPointsOfInflection * = 366;
      FindingPointsOfInflectionSTR = "Finding points of inflection";
      PointsOfInflection * = 367;
      PointsOfInflectionSTR = "Points of inflection";
      FindingIntersections * = 368;
      FindingIntersectionsSTR = "Finding intersections";
      Intersections * = 369;
      IntersectionsSTR = "Intersections";
      ForRange * = 370;
      ForRangeSTR = "for";
      And * = 371;
      AndSTR = "and";
      CompleteFunctionAnalysis * = 372;
      CompleteFunctionAnalysisSTR = "Complete function analysis";
      Print * = 373;
      PrintSTR = "Print";
      TextBox * = 374;
      TextBoxSTR = "Text box";
      AnalysisOfFunction * = 375;
      AnalysisOfFunctionSTR = "Analysis of function";
      Derivatives * = 376;
      DerivativesSTR = "Derivatives";
      NoSimpleSymmetryFound * = 377;
      NoSimpleSymmetryFoundSTR = "No simple symmetry found!";
      AxialSymmetryToYAxis * = 378;
      AxialSymmetryToYAxisSTR = "Axial symmetry to y-axis.";
      PointSymmetryToOrigin * = 379;
      PointSymmetryToOriginSTR = "Point symmetry to origin.";
      NoZerosFound * = 380;
      NoZerosFoundSTR = "No zeros found!";
      NoExtremePointsFound * = 381;
      NoExtremePointsFoundSTR = "No extreme points found!";
      NoPointsOfInflectionFound * = 382;
      NoPointsOfInflectionFoundSTR = "No points of inflection found!";
      Symmetry * = 383;
      SymmetrySTR = "Symmetry";
      create * = 384;
      createSTR = "create";
      MaxDegree * = 385;
      MaxDegreeSTR = "max. degree:";
      search * = 386;
      searchSTR = "search";
      MaximumPoint * = 387;
      MaximumPointSTR = "Maximum point";
      MinimumPoint * = 388;
      MinimumPointSTR = "Minimum point";
      NoElementSelected * = 389;
      NoElementSelectedSTR = "No element selected!";
      AboveXAxis * = 390;
      AboveXAxisSTR = "Above x-axis";
      BelowXAxis * = 391;
      BelowXAxisSTR = "below x-axis";
      RightOfYAxis * = 392;
      RightOfYAxisSTR = "Right of y-axis";
      LeftOfYAxis * = 393;
      LeftOfYAxisSTR = "Left of y-axis";
      RightOfXValue * = 394;
      RightOfXValueSTR = "Right of x-value";
      LeftOfXValue * = 395;
      LeftOfXValueSTR = "Left of x-value";
      AboveYValue * = 396;
      AboveYValueSTR = "Above y-value";
      BelowYValue * = 397;
      BelowYValueSTR = "Below y-value";
      AboveFunction * = 398;
      AboveFunctionSTR = "Above function";
      BelowFunction * = 399;
      BelowFunctionSTR = "Below function";
      RightAboveP * = 400;
      RightAbovePSTR = "Right, above P";
      LeftAboveP * = 401;
      LeftAbovePSTR = "Left, above P";
      RightBelowP * = 402;
      RightBelowPSTR = "Right, below P";
      LeftBelowP * = 403;
      LeftBelowPSTR = "Left, below P";
      RightOfMarker * = 404;
      RightOfMarkerSTR = "Right of marker";
      LeftOfMarker * = 405;
      LeftOfMarkerSTR = "Left of marker";
      ChangeHatching * = 406;
      ChangeHatchingSTR = "Change hatching";
      NewElement * = 407;
      NewElementSTR = "New element";
      DelElement * = 408;
      DelElementSTR = "Delete element";
      HatchingBounds * = 409;
      HatchingBoundsSTR = "Hatching bounds";
      HatchingDesign * = 410;
      HatchingDesignSTR = "Hatching design";
      BoundaryElements * = 411;
      BoundaryElementsSTR = "Boundary elements";
      CurrentElement * = 412;
      CurrentElementSTR = "Current element";
      XAxis * = 413;
      XAxisSTR = "x-axis";
      YAxis * = 414;
      YAxisSTR = "y-axis";
      XValue * = 415;
      XValueSTR = "x-value";
      YValue * = 416;
      YValueSTR = "y-value";
      HatchingName * = 417;
      HatchingNameSTR = "Hatching name";
      ClearBackground * = 418;
      ClearBackgroundSTR = "Clear background";
      HatchingToTheBack * = 419;
      HatchingToTheBackSTR = "Hatching to the back";
      ElementsEx * = 420;
      ElementsExSTR = "elements!";
      SelectPoint * = 421;
      SelectPointSTR = "Select point";
      SelectMarker * = 422;
      SelectMarkerSTR = "Select marker";
      Calculate * = 423;
      CalculateSTR = "Calculate";
      DefaultHatching * = 424;
      DefaultHatchingSTR = "Default hatching";
      CustomHatching * = 425;
      CustomHatchingSTR = "Custom hatching";
      SurfaceBetweenFunctions * = 426;
      SurfaceBetweenFunctionsSTR = "Surface between functions";
      HatchSurface * = 427;
      HatchSurfaceSTR = "Hatch surface";
      From * = 428;
      FromSTR = "from";
      To * = 429;
      ToSTR = "to";
      ResultDP * = 430;
      ResultDPSTR = "Result:";
      Absolute * = 431;
      AbsoluteSTR = "absolute";
      Oriented * = 432;
      OrientedSTR = "oriented";
      Rotation * = 433;
      RotationSTR = "Rotation";
      Below * = 434;
      BelowSTR = "Below";
      Above * = 435;
      AboveSTR = "Above";
      LowerLimit * = 436;
      LowerLimitSTR = "Lower limit";
      UpperLimit * = 437;
      UpperLimitSTR = "Upper limit";
      TheUpperLimitMustBe * = 438;
      TheUpperLimitMustBeSTR = "The upper limit must be";
      HigherThanTheLowerLimit * = 439;
      HigherThanTheLowerLimitSTR = "higher than the lower limit!";
      ItCannotBeIntegrated * = 440;
      ItCannotBeIntegratedSTR = "It cannot be integrated";
      OverADefinitionGap * = 441;
      OverADefinitionGapSTR = "over a definition gap!";
      ChangeZoom * = 442;
      ChangeZoomSTR = "Change zoom";
      ZoomInPerCent * = 443;
      ZoomInPerCentSTR = "Zoom in %";
      ChangeRasterGrid * = 444;
      ChangeRasterGridSTR = "Change grid";
      DisplayRasterGrid * = 445;
      DisplayRasterGridSTR = "Display grid";
      Snap * = 446;
      SnapSTR = "Snap";
      AdaptBoxSize * = 447;
      AdaptBoxSizeSTR = "Adapt box size";
      units * = 448;
      unitsSTR = "units";
      cm * = 449;
      cmSTR = "cm";
      ChangeBox * = 450;
      ChangeBoxSTR = "Change box";
      BoxCoordinates * = 451;
      BoxCoordinatesSTR = "Box coordinates";
      Position * = 452;
      PositionSTR = "Position";
      Dimensions * = 453;
      DimensionsSTR = "Dimensions";
      BoxParameters * = 454;
      BoxParametersSTR = "Box parameters";
      Left * = 455;
      LeftSTR = "Left";
      Right * = 456;
      RightSTR = "Right";
      Top * = 457;
      TopSTR = "Top";
      LockBox * = 458;
      LockBoxSTR = "Lock box";
      DisplayBoxFast * = 459;
      DisplayBoxFastSTR = "Fast display";
      GlobalPageSettings * = 460;
      GlobalPageSettingsSTR = "Page size";
      PageDimensions * = 461;
      PageDimensionsSTR = "Dimensions";
      Defaults * = 462;
      DefaultsSTR = "Defaults";
      custom * = 463;
      customSTR = "Custom";
      CouldntLoadFont1 * = 464;
      CouldntLoadFont1STR = "Couldn't load";
      CouldntLoadFont2 * = 465;
      CouldntLoadFont2STR = "font!";
      SelectFont * = 466;
      SelectFontSTR = "Select font";
      Selection * = 467;
      SelectionSTR = "Selection";
      Size * = 468;
      SizeSTR = "Size";
      UseAutoFont * = 469;
      UseAutoFontSTR = "Use auto-font";
      FontsEx * = 470;
      FontsExSTR = "fonts!";
      FontConversion * = 471;
      FontConversionSTR = "Font conversion";
      NewFont * = 472;
      NewFontSTR = "New font";
      DelFont * = 473;
      DelFontSTR = "Delete font";
      MathModeFont * = 474;
      MathModeFontSTR = "Math Mode font";
      LayoutModeFont * = 475;
      LayoutModeFontSTR = "Layout Mode font";
      MathModeSize * = 476;
      MathModeSizeSTR = "Math Mode size";
      LayoutModeSize * = 477;
      LayoutModeSizeSTR = "Layout Mode size";
      Pixels * = 478;
      PixelsSTR = "Pixels";
      PicaPoints * = 479;
      PicaPointsSTR = "Points";
      NoColorsEntered1 * = 480;
      NoColorsEntered1STR = "No colors";
      NoColorsEntered2 * = 481;
      NoColorsEntered2STR = "entered!";
      ChangeColors * = 482;
      ChangeColorsSTR = "Change colors";
      NewColor * = 483;
      NewColorSTR = "New color";
      DelColor * = 484;
      DelColorSTR = "Delete color";
      CurrentColor * = 485;
      CurrentColorSTR = "Current color";
      SelectColor * = 486;
      SelectColorSTR = "Select color";
      ColorwheelNotAvailable1 * = 487;
      ColorwheelNotAvailable1STR = "Color wheel not available";
      ColorwheelNotAvailable2 * = 488;
      ColorwheelNotAvailable2STR = "before AmigaDOS 3.0!";
      ColorsEx * = 489;
      ColorsExSTR = "colors!";
      White * = 490;
      WhiteSTR = "White";
      Hair * = 491;
      HairSTR = "Hair";
      ChangeTextLine * = 492;
      ChangeTextLineSTR = "Change text line";
      TextLine * = 493;
      TextLineSTR = "Text line";
      TextInput * = 494;
      TextInputSTR = "Text input";
      FillUp * = 495;
      FillUpSTR = "Fill";
      SelectTextColor * = 496;
      SelectTextColorSTR = "Select text color";
      TextColor * = 497;
      TextColorSTR = "Text color";
      SelectBackgroundColor * = 498;
      SelectBackgroundColorSTR = "Select background color";
      ChangeGraphic * = 499;
      ChangeGraphicSTR = "Change graphic";
      Ellipse * = 500;
      EllipseSTR = "Ellipse";
      Rectangle * = 501;
      RectangleSTR = "Rectangle";
      LayoutLine * = 502;
      LayoutLineSTR = "Line";
      OutlineColor * = 503;
      OutlineColorSTR = "Outline color";
      FillColor * = 504;
      FillColorSTR = "Fill color";
      LineColor * = 505;
      LineColorSTR = "Line color";
      SelectOutlineColor * = 506;
      SelectOutlineColorSTR = "Select outline color";
      SelectFillColor * = 507;
      SelectFillColorSTR = "Select fill color";
      ColorConversion * = 508;
      ColorConversionSTR = "Color conversion";
      MathModeColor * = 509;
      MathModeColorSTR = "Math Mode color";
      DocumentColor * = 510;
      DocumentColorSTR = "Document color";
      SelectDocumentColor * = 511;
      SelectDocumentColorSTR = "Select document color";
      LineThicknessConversion * = 512;
      LineThicknessConversionSTR = "Line thickness conversion";
      MathModeThickness * = 513;
      MathModeThicknessSTR = "Math Mode thickness";
      PrintThickness * = 514;
      PrintThicknessSTR = "Print thickness";
      AxisSystemConversion * = 515;
      AxisSystemConversionSTR = "Axis system conversion";
      AxisSystemColor * = 516;
      AxisSystemColorSTR = "Axis system color";
      SelectAxisSystemColor * = 517;
      SelectAxisSystemColorSTR = "Select axis system color";
      BackgroundGridConversion * = 518;
      BackgroundGridConversionSTR = "Grid conversion";
      SelectGridColor * = 519;
      SelectGridColorSTR = "Select grid color";
      GridColor * = 520;
      GridColorSTR = "Grid color";
      ChangeBoxContents * = 521;
      ChangeBoxContentsSTR = "Change box contents";
      AxisSystem * = 522;
      AxisSystemSTR = "Axis system";
      BackgroundGrid * = 523;
      BackgroundGridSTR = "Grid";
      BoxContents * = 524;
      BoxContentsSTR = "Box contents";
      GraphicColor * = 525;
      GraphicColorSTR = "Graphic-color";
      SelectGraphicColor * = 526;
      SelectGraphicColorSTR = "Select graphic-color";
      LayoutWorkingWindowTitle * = 527;
      LayoutWorkingWindowTitleSTR = "Layout";
      LayoutWorkingScreenTitle * = 528;
      LayoutWorkingScreenTitleSTR = "Layout screen";
      PrintingPage * = 529;
      PrintingPageSTR = "Printing page";
      SelectASCIIFile * = 530;
      SelectASCIIFileSTR = "Select ASCII file";
      CouldntOpenFile1 * = 531;
      CouldntOpenFile1STR = "Couldn't open";
      CouldntOpenFile2 * = 532;
      CouldntOpenFile2STR = "file!";
      ChangeFormula * = 533;
      ChangeFormulaSTR = "Change formula";
      Formula * = 534;
      FormulaSTR = "Formula";
      PrinterSettings * = 535;
      PrinterSettingsSTR = "Printersettings";
      QualityPrintout * = 536;
      QualityPrintoutSTR = "High quality";
      DraftPrintout * = 537;
      DraftPrintoutSTR = "Draft";
      Portrait * = 538;
      PortraitSTR = "Portrait";
      Landscape * = 539;
      LandscapeSTR = "Landscape";
      ResolutionPrinter * = 540;
      ResolutionPrinterSTR = "Resolution";
      GrayScaleRastering * = 541;
      GrayScaleRasteringSTR = "Grayscale rastering";
      ColorCorrection * = 542;
      ColorCorrectionSTR = "Color correction";
      NumberGraySteps * = 543;
      NumberGrayStepsSTR = "Number of graysteps";
      Driver * = 544;
      DriverSTR = "Driver";
      BlackAndWhite * = 545;
      BlackAndWhiteSTR = "Black & White";
      GrayScale * = 546;
      GrayScaleSTR = "Grayscale";
      Ordered * = 547;
      OrderedSTR = "Ordered";
      Halftone * = 548;
      HalftoneSTR = "Halftone";
      FloydSteinberg * = 549;
      FloydSteinbergSTR = "Floyd-Steinberg";
      Fonts * = 550;
      FontsSTR = "Fonts";
      SortFonts * = 551;
      SortFontsSTR = "Sort fonts";
      NewPath * = 552;
      NewPathSTR = "New path";
      DelPath * = 553;
      DelPathSTR = "Delete path";
      PathCurrentFont * = 554;
      PathCurrentFontSTR = "Path to current font";
      PathsEx * = 555;
      PathsExSTR = "paths!";
      ScreenPresentation * = 556;
      ScreenPresentationSTR = "Screen presentation";
      MaximumDistortionInPerCent * = 557;
      MaximumDistortionInPerCentSTR = "Maximum distortion in %";
      QuitLayout * = 558;
      QuitLayoutSTR = "Quit layout";
      SetTextbox * = 559;
      SetTextboxSTR = "Text box";
      SetTextline * = 560;
      SetTextlineSTR = "Text line";
      DrawLine * = 561;
      DrawLineSTR = "Line";
      SetRectangle * = 562;
      SetRectangleSTR = "Rectangle";
      SetEllipse * = 563;
      SetEllipseSTR = "Ellipse";
      Work * = 564;
      WorkSTR = "Work";
      DeleteActiveBox * = 565;
      DeleteActiveBoxSTR = "Delete active box";
      ChangeActiveBox * = 566;
      ChangeActiveBoxSTR = "Change active box";
      Script * = 567;
      ScriptSTR = "Script";
      Style * = 568;
      StyleSTR = "Style";
      Alignment * = 569;
      AlignmentSTR = "Alignment";
      Center * = 570;
      CenterSTR = "Center";
      Justify * = 571;
      JustifySTR = "Justify";
      ImportASCII * = 572;
      ImportASCIISTR = "Import ASCII";
      InsertFormula * = 573;
      InsertFormulaSTR = "Insert formula";
      Conversion * = 574;
      ConversionSTR = "Conversion";
      Preferences * = 575;
      PreferencesSTR = "Preferences";
      Zoom * = 576;
      ZoomSTR = "Zoom";
      RasterGrid * = 577;
      RasterGridSTR = "Grid";
      DocumentColors * = 578;
      DocumentColorsSTR = "Document colors";
      ShowInactive * = 579;
      ShowInactiveSTR = "Show inactive";
      ToolBox * = 580;
      ToolBoxSTR = "Toolbox";
      CustomScreen * = 581;
      CustomScreenSTR = "Custom screen";
      Printing * = 582;
      PrintingSTR = "Printing";
      AbortPrintout * = 583;
      AbortPrintoutSTR = "Abort printout";
      ScalingFonts * = 584;
      ScalingFontsSTR = "Scaling fonts";
      RequestingPrintoutMemory * = 585;
      RequestingPrintoutMemorySTR = "Requesting memory";
      ReallyAbortPrintout1 * = 586;
      ReallyAbortPrintout1STR = "Really abort";
      ReallyAbortPrintout2 * = 587;
      ReallyAbortPrintout2STR = "printout?";
      FunctionOnlyOnFunctionBoxes1 * = 588;
      FunctionOnlyOnFunctionBoxes1STR = "Function only allowed on";
      FunctionOnlyOnFunctionBoxes2 * = 589;
      FunctionOnlyOnFunctionBoxes2STR = "boxes with graphs!";
      Page * = 590;
      PageSTR = "Page";
      rest * = 591;
      restSTR = "rest";
      Cyan * = 592;
      CyanSTR = "Cyan";
      Magenta * = 593;
      MagentaSTR = "Magenta";
      Yellow * = 594;
      YellowSTR = "Yellow";
      Black * = 595;
      BlackSTR = "Black";
      Gray * = 596;
      GraySTR = "Gray";
      Red * = 597;
      RedSTR = "Red";
      Green * = 598;
      GreenSTR = "Green";
      Blue * = 599;
      BlueSTR = "Blue";
      AllRightsReserved * = 600;
      AllRightsReservedSTR = "All rights reserved";
      ThisIsADemo1 * = 601;
      ThisIsADemo1STR = "This is an unregistered";
      ThisIsADemo2 * = 602;
      ThisIsADemo2STR = "demo version!";
      ThisVersionIsRegisteredTo * = 603;
      ThisVersionIsRegisteredToSTR = "This version is registered to:";
      WindowMustContain2Functions1 * = 604;
      WindowMustContain2Functions1STR = "The window must contain at least";
      WindowMustContain2Functions2 * = 605;
      WindowMustContain2Functions2STR = "2 functions for this operation!";
      LoadDocument * = 606;
      LoadDocumentSTR = "Load document";
      SaveDocument * = 607;
      SaveDocumentSTR = "Save document";
      LoadConfiguration * = 608;
      LoadConfigurationSTR = "Load configuration";
      SaveConfiguration * = 609;
      SaveConfigurationSTR = "Save configuration";
      FileAlreadyExists * = 610;
      FileAlreadyExistsSTR = "File already exists!";
      Overwrite * = 611;
      OverwriteSTR = "Overwrite?";
      CouldntLoadFileDP * = 612;
      CouldntLoadFileDPSTR = "Couldn't load file:";
      VersionTooLate * = 613;
      VersionTooLateSTR = "Version too late!";
      ChecksumError * = 614;
      ChecksumErrorSTR = "Checksum error!";
      NoValidAnalayConfigurationFile1 * = 615;
      NoValidAnalayConfigurationFile1STR = "No valid";
      NoValidAnalayConfigurationFile2 * = 616;
      NoValidAnalayConfigurationFile2STR = "Analay configuration file!";
      NoValidAnalayDocumentFile1 * = 617;
      NoValidAnalayDocumentFile1STR = "No valid";
      NoValidAnalayDocumentFile2 * = 618;
      NoValidAnalayDocumentFile2STR = "Analay document file!";
      PIName * = 619;
      PINameSTR = "Pi";
      EulerName * = 620;
      EulerNameSTR = "Base of natural logarithms";
      PlanckName * = 621;
      PlanckNameSTR = "Planck's constant";
      LightSpeedName * = 622;
      LightSpeedNameSTR = "Speed of light in vacuum";
      ElementaryChargeName * = 623;
      ElementaryChargeNameSTR = "Elementary charge";
      ElectronMassName * = 624;
      ElectronMassNameSTR = "Electron rest mass";
      NeutronMassName * = 625;
      NeutronMassNameSTR = "Neutron rest mass";
      ProtonMassName * = 626;
      ProtonMassNameSTR = "Proton rest mass";
      AtomicMassUnitName * = 627;
      AtomicMassUnitNameSTR = "Atomic mass unit";
      MolarVolumeIdealGasName * = 628;
      MolarVolumeIdealGasNameSTR = "Molar volume, ideal gas";
      AvogadroName * = 629;
      AvogadroNameSTR = "Avogadro's constant";
      GravitationName * = 630;
      GravitationNameSTR = "Gravitational constant";
      MolarGasConstantName * = 631;
      MolarGasConstantNameSTR = "Molar gas constant";
      NormalPressureName * = 632;
      NormalPressureNameSTR = "Normal atmospheric pressure";
      BoltzmannName * = 633;
      BoltzmannNameSTR = "Boltzmann's constant";
      PermittivityName * = 634;
      PermittivityNameSTR = "Permittivity of vacuum";
      PermeabilityName * = 635;
      PermeabilityNameSTR = "Permeability of vacuum";

TYPE AppString = STRUCT
       id  : LONGINT;
       str : e.STRPTR;
     END;
     AppStringArray = ARRAY 636 OF AppString;

CONST AppStrings = AppStringArray (
        GuideName, y.ADR(GuideNameSTR),
        OK, y.ADR(OKSTR),
        Cancel, y.ADR(CancelSTR),
        Yes, y.ADR(YesSTR),
        No, y.ADR(NoSTR),
        Help, y.ADR(HelpSTR),
        None, y.ADR(NoneSTR),
        Program, y.ADR(ProgramSTR),
        Load, y.ADR(LoadSTR),
        Save, y.ADR(SaveSTR),
        SaveAs, y.ADR(SaveAsSTR),
        Layout, y.ADR(LayoutSTR),
        About, y.ADR(AboutSTR),
        Quit, y.ADR(QuitSTR),
        Function, y.ADR(FunctionSTR),
        Input, y.ADR(InputSTR),
        DefinitionDomain, y.ADR(DefinitionDomainSTR),
        Connect, y.ADR(ConnectSTR),
        Process, y.ADR(ProcessSTR),
        ChangeConstants, y.ADR(ChangeConstantsSTR),
        QuickEnter, y.ADR(QuickEnterSTR),
        Windows, y.ADR(WindowsSTR),
        Create, y.ADR(CreateSTR),
        Settings, y.ADR(SettingsSTR),
        AxisLimits, y.ADR(AxisLimitsSTR),
        AxisDesign, y.ADR(AxisDesignSTR),
        Grid, y.ADR(GridSTR),
        GraphDesign, y.ADR(GraphDesignSTR),
        Text, y.ADR(TextSTR),
        Place, y.ADR(PlaceSTR),
        Change, y.ADR(ChangeSTR),
        Delete, y.ADR(DeleteSTR),
        Default, y.ADR(DefaultSTR),
        Point, y.ADR(PointSTR),
        Marker, y.ADR(MarkerSTR),
        Hatching, y.ADR(HatchingSTR),
        Analysis, y.ADR(AnalysisSTR),
        FindZeros, y.ADR(FindZerosSTR),
        FindExtremes, y.ADR(FindExtremesSTR),
        FindGaps, y.ADR(FindGapsSTR),
        FindInflections, y.ADR(FindInflectionsSTR),
        FindIntersections, y.ADR(FindIntersectionsSTR),
        CompleteAnalysis, y.ADR(CompleteAnalysisSTR),
        CompleteSettings, y.ADR(CompleteSettingsSTR),
        CompleteAnalysisSettings, y.ADR(CompleteAnalysisSettingsSTR),
        CalcArea, y.ADR(CalcAreaSTR),
        Special, y.ADR(SpecialSTR),
        Legend, y.ADR(LegendSTR),
        Table, y.ADR(TableSTR),
        List, y.ADR(ListSTR),
        SettingsMenu, y.ADR(SettingsMenuSTR),
        ScreenModeMenu, y.ADR(ScreenModeMenuSTR),
        ScreenColors, y.ADR(ScreenColorsSTR),
        Priorities, y.ADR(PrioritiesSTR),
        UseWBScreen, y.ADR(UseWBScreenSTR),
        QuickSelect, y.ADR(QuickSelectSTR),
        AutoActiveWindow, y.ADR(AutoActiveWindowSTR),
        CloneWB, y.ADR(CloneWBSTR),
        DerivativeOf, y.ADR(DerivativeOfSTR),
        Name, y.ADR(NameSTR),
        Symbol, y.ADR(SymbolSTR),
        Comment, y.ADR(CommentSTR),
        Value, y.ADR(ValueSTR),
        ChangeConstantsReq, y.ADR(ChangeConstantsReqSTR),
        InternalConstants, y.ADR(InternalConstantsSTR),
        TemporaryConstants, y.ADR(TemporaryConstantsSTR),
        NewConstant, y.ADR(NewConstantSTR),
        DelConstant, y.ADR(DelConstantSTR),
        CopyConstant, y.ADR(CopyConstantSTR),
        ConstantsEx, y.ADR(ConstantsExSTR),
        Constant, y.ADR(ConstantSTR),
        ConstantsMustNot, y.ADR(ConstantsMustNotSTR),
        DependOnItself, y.ADR(DependOnItselfSTR),
        SetScreenColors, y.ADR(SetScreenColorsSTR),
        Color, y.ADR(ColorSTR),
        Colors, y.ADR(ColorsSTR),
        RedDP, y.ADR(RedDPSTR),
        GreenDP, y.ADR(GreenDPSTR),
        BlueDP, y.ADR(BlueDPSTR),
        ReservedDP, y.ADR(ReservedDPSTR),
        EnterPoint, y.ADR(EnterPointSTR),
        PointCoordinates, y.ADR(PointCoordinatesSTR),
        XCoord, y.ADR(XCoordSTR),
        YCoord, y.ADR(YCoordSTR),
        ReflectFunction, y.ADR(ReflectFunctionSTR),
        ThroughLineX, y.ADR(ThroughLineXSTR),
        ThroughLineY, y.ADR(ThroughLineYSTR),
        ThroughPoint, y.ADR(ThroughPointSTR),
        EnterFunctions, y.ADR(EnterFunctionsSTR),
        NewFunction, y.ADR(NewFunctionSTR),
        DelFunction, y.ADR(DelFunctionSTR),
        CopyFunction, y.ADR(CopyFunctionSTR),
        AppendFunction, y.ADR(AppendFunctionSTR),
        DeriveFunction, y.ADR(DeriveFunctionSTR),
        NewVariable, y.ADR(NewVariableSTR),
        DelVariable, y.ADR(DelVariableSTR),
        CopyVariable, y.ADR(CopyVariableSTR),
        Functions, y.ADR(FunctionsSTR),
        Variables, y.ADR(VariablesSTR),
        FunctionsEx, y.ADR(FunctionsExSTR),
        VariablesEx, y.ADR(VariablesExSTR),
        ErrorInVariableInput, y.ADR(ErrorInVariableInputSTR),
        VariableNameMissing, y.ADR(VariableNameMissingSTR),
        LowerLimitMissing, y.ADR(LowerLimitMissingSTR),
        UpperLimitMissing, y.ADR(UpperLimitMissingSTR),
        WarningDP, y.ADR(WarningDPSTR),
        bracketsNotClosed, y.ADR(bracketsNotClosedSTR),
        TooManyBracketsClosed, y.ADR(TooManyBracketsClosedSTR),
        ErrorInFunctionInput, y.ADR(ErrorInFunctionInputSTR),
        IllegalUseOfMathematicalSign, y.ADR(IllegalUseOfMathematicalSignSTR),
        ErrorInNumberFormat, y.ADR(ErrorInNumberFormatSTR),
        OpeningBracketExpected, y.ADR(OpeningBracketExpectedSTR),
        MathematicalSignExpected, y.ADR(MathematicalSignExpectedSTR),
        OperandExpected, y.ADR(OperandExpectedSTR),
        ProcessFunctions, y.ADR(ProcessFunctionsSTR),
        TangentAtPoint, y.ADR(TangentAtPointSTR),
        NormalAtPoint, y.ADR(NormalAtPointSTR),
        Derivative, y.ADR(DerivativeSTR),
        DeriveFor, y.ADR(DeriveForSTR),
        TangentCannotBe, y.ADR(TangentCannotBeSTR),
        DrawnAtAGapTangent, y.ADR(DrawnAtAGapTangentSTR),
        NormalCannotBe, y.ADR(NormalCannotBeSTR),
        DrawnAtAGapNormal, y.ADR(DrawnAtAGapNormalSTR),
        ReflectionOf, y.ADR(ReflectionOfSTR),
        EnterFunction, y.ADR(EnterFunctionSTR),
        Auto, y.ADR(AutoSTR),
        CreateWindows, y.ADR(CreateWindowsSTR),
        NoWindow, y.ADR(NoWindowSTR),
        SelectedEx, y.ADR(SelectedExSTR),
        NewWindow, y.ADR(NewWindowSTR),
        DelWindow, y.ADR(DelWindowSTR),
        CopyWindow, y.ADR(CopyWindowSTR),
        AppendWindow, y.ADR(AppendWindowSTR),
        InsertFunction, y.ADR(InsertFunctionSTR),
        DelFunctionCreateWindows, y.ADR(DelFunctionCreateWindowsSTR),
        WindowsEx, y.ADR(WindowsExSTR),
        Window, y.ADR(WindowSTR),
        WindowDP, y.ADR(WindowDPSTR),
        SelectedFunctions, y.ADR(SelectedFunctionsSTR),
        AvailableFunctions, y.ADR(AvailableFunctionsSTR),
        ChangeUserDomain, y.ADR(ChangeUserDomainSTR),
        NewDomain, y.ADR(NewDomainSTR),
        DelDomain, y.ADR(DelDomainSTR),
        CopyDomain, y.ADR(CopyDomainSTR),
        UserDefinitionDomain, y.ADR(UserDefinitionDomainSTR),
        DefinedAt, y.ADR(DefinedAtSTR),
        AllX, y.ADR(AllXSTR),
        ErrorInDomainInput, y.ADR(ErrorInDomainInputSTR),
        SymbolsMissing, y.ADR(SymbolsMissingSTR),
        DomainMustContainAtLeast, y.ADR(DomainMustContainAtLeastSTR),
        TwoLimits, y.ADR(TwoLimitsSTR),
        MissingFourth, y.ADR(MissingFourthSTR),
        ConnectFunctions, y.ADR(ConnectFunctionsSTR),
        NewConnection, y.ADR(NewConnectionSTR),
        DelConnection, y.ADR(DelConnectionSTR),
        CopyConnection, y.ADR(CopyConnectionSTR),
        NoConnection, y.ADR(NoConnectionSTR),
        Connections, y.ADR(ConnectionsSTR),
        ConnectionsEx, y.ADR(ConnectionsExSTR),
        Connection, y.ADR(ConnectionSTR),
        ConnectedFunctions, y.ADR(ConnectedFunctionsSTR),
        Grid1On, y.ADR(Grid1OnSTR),
        Grid2On, y.ADR(Grid2OnSTR),
        GridDesign, y.ADR(GridDesignSTR),
        GridSize, y.ADR(GridSizeSTR),
        StartCoordinates, y.ADR(StartCoordinatesSTR),
        LinePattern, y.ADR(LinePatternSTR),
        LineThickness, y.ADR(LineThicknessSTR),
        Font, y.ADR(FontSTR),
        AxisSystemOn, y.ADR(AxisSystemOnSTR),
        AxisRealDesign, y.ADR(AxisRealDesignSTR),
        Scale, y.ADR(ScaleSTR),
        Values, y.ADR(ValuesSTR),
        Ticks1, y.ADR(Ticks1STR),
        Ticks2, y.ADR(Ticks2STR),
        XAxisLabel, y.ADR(XAxisLabelSTR),
        YAxisLabel, y.ADR(YAxisLabelSTR),
        Arrow, y.ADR(ArrowSTR),
        SelectAxisLabelsFont, y.ADR(SelectAxisLabelsFontSTR),
        ChangeAxisLimits, y.ADR(ChangeAxisLimitsSTR),
        CartesianAxisLimits, y.ADR(CartesianAxisLimitsSTR),
        UndoChanges, y.ADR(UndoChangesSTR),
        ScreenMode, y.ADR(ScreenModeSTR),
        Width, y.ADR(WidthSTR),
        Height, y.ADR(HeightSTR),
        Interlace, y.ADR(InterlaceSTR),
        NTSC, y.ADR(NTSCSTR),
        NoResolutions, y.ADR(NoResolutionsSTR),
        FoundEx, y.ADR(FoundExSTR),
        ScreenResolution, y.ADR(ScreenResolutionSTR),
        FunctionDesign, y.ADR(FunctionDesignSTR),
        FunctionFamily, y.ADR(FunctionFamilySTR),
        Design, y.ADR(DesignSTR),
        FunctionFamilies, y.ADR(FunctionFamiliesSTR),
        NoneFemSing, y.ADR(NoneFemSingSTR),
        FamilyEx, y.ADR(FamilyExSTR),
        NumberFormat, y.ADR(NumberFormatSTR),
        Exponent, y.ADR(ExponentSTR),
        DecimalPlaces, y.ADR(DecimalPlacesSTR),
        WindowSettings, y.ADR(WindowSettingsSTR),
        FunctionDisplayed, y.ADR(FunctionDisplayedSTR),
        FunctionsDisplayed, y.ADR(FunctionsDisplayedSTR),
        ModeDP, y.ADR(ModeDPSTR),
        Cartesian2D, y.ADR(Cartesian2DSTR),
        Transparent, y.ADR(TransparentSTR),
        BorderFree, y.ADR(BorderFreeSTR),
        AutoYRange, y.ADR(AutoYRangeSTR),
        AutoAxisLabels, y.ADR(AutoAxisLabelsSTR),
        AutoGrid, y.ADR(AutoGridSTR),
        BackgroundColor, y.ADR(BackgroundColorSTR),
        ForegroundColor, y.ADR(ForegroundColorSTR),
        NumberOfSegments, y.ADR(NumberOfSegmentsSTR),
        ValueRange, y.ADR(ValueRangeSTR),
        Start, y.ADR(StartSTR),
        End, y.ADR(EndSTR),
        Step, y.ADR(StepSTR),
        SetPriorities, y.ADR(SetPrioritiesSTR),
        MathMode, y.ADR(MathModeSTR),
        LayoutMode, y.ADR(LayoutModeSTR),
        MathRequesters, y.ADR(MathRequestersSTR),
        AfterWindow, y.ADR(AfterWindowSTR),
        DeleteListLegend, y.ADR(DeleteListLegendSTR),
        AppendWindowLegend, y.ADR(AppendWindowLegendSTR),
        InsertWindowLegend, y.ADR(InsertWindowLegendSTR),
        FunctionSymbol, y.ADR(FunctionSymbolSTR),
        FamilySymbol, y.ADR(FamilySymbolSTR),
        ChangeLegend, y.ADR(ChangeLegendSTR),
        AppendLine, y.ADR(AppendLineSTR),
        InsertLine, y.ADR(InsertLineSTR),
        DeleteLine, y.ADR(DeleteLineSTR),
        LegendGeneral, y.ADR(LegendGeneralSTR),
        CurrentLine, y.ADR(CurrentLineSTR),
        LegendPreview, y.ADR(LegendPreviewSTR),
        FunctionsUniform, y.ADR(FunctionsUniformSTR),
        FamiliesUniform, y.ADR(FamiliesUniformSTR),
        IndentFamilies, y.ADR(IndentFamiliesSTR),
        WindowModel, y.ADR(WindowModelSTR),
        PointDesign, y.ADR(PointDesignSTR),
        Family, y.ADR(FamilySTR),
        SelectWindow, y.ADR(SelectWindowSTR),
        SelectLegend, y.ADR(SelectLegendSTR),
        SelectTable, y.ADR(SelectTableSTR),
        SelectList, y.ADR(SelectListSTR),
        SelectHatching, y.ADR(SelectHatchingSTR),
        AtTheMomentNo, y.ADR(AtTheMomentNoSTR),
        InThisWindowNo, y.ADR(InThisWindowNoSTR),
        WindowsAreDisplayed, y.ADR(WindowsAreDisplayedSTR),
        LegendsAreDisplayed, y.ADR(LegendsAreDisplayedSTR),
        TablesAreDisplayed, y.ADR(TablesAreDisplayedSTR),
        ListsAreDisplayed, y.ADR(ListsAreDisplayedSTR),
        FunctionsAreEntered, y.ADR(FunctionsAreEnteredSTR),
        TextsAreDisplayed, y.ADR(TextsAreDisplayedSTR),
        PointsAreDisplayed, y.ADR(PointsAreDisplayedSTR),
        MarkersAreDisplayed, y.ADR(MarkersAreDisplayedSTR),
        HatchingsAreDisplayed, y.ADR(HatchingsAreDisplayedSTR),
        FunctionsAreDisplayed, y.ADR(FunctionsAreDisplayedSTR),
        ChangeDesign, y.ADR(ChangeDesignSTR),
        Preview, y.ADR(PreviewSTR),
        HorizontalSeparation, y.ADR(HorizontalSeparationSTR),
        VerticalSeparation, y.ADR(VerticalSeparationSTR),
        RowsEx, y.ADR(RowsExSTR),
        ColumnsEx, y.ADR(ColumnsExSTR),
        ChangeList, y.ADR(ChangeListSTR),
        AddColumn, y.ADR(AddColumnSTR),
        InsertColumn, y.ADR(InsertColumnSTR),
        DeleteColumn, y.ADR(DeleteColumnSTR),
        ListDesign, y.ADR(ListDesignSTR),
        AppendField, y.ADR(AppendFieldSTR),
        InsertField, y.ADR(InsertFieldSTR),
        DeleteField, y.ADR(DeleteFieldSTR),
        CalcColumn, y.ADR(CalcColumnSTR),
        SelectColumnWithXValues, y.ADR(SelectColumnWithXValuesSTR),
        ListGeneral, y.ADR(ListGeneralSTR),
        CurrentColumn, y.ADR(CurrentColumnSTR),
        ListPreview, y.ADR(ListPreviewSTR),
        ColumnWidthUniform, y.ADR(ColumnWidthUniformSTR),
        CenterText, y.ADR(CenterTextSTR),
        DecimalTabulator, y.ADR(DecimalTabulatorSTR),
        SeparateHeadline, y.ADR(SeparateHeadlineSTR),
        NumberFieldsUniform, y.ADR(NumberFieldsUniformSTR),
        Entries, y.ADR(EntriesSTR),
        SelectFontForList, y.ADR(SelectFontForListSTR),
        TheListMustContainAtLeast, y.ADR(TheListMustContainAtLeastSTR),
        OneColumnForThisFunction, y.ADR(OneColumnForThisFunctionSTR),
        TwoColumnsForThisFunction, y.ADR(TwoColumnsForThisFunctionSTR),
        SelectFunction, y.ADR(SelectFunctionSTR),
        SelectFunction1, y.ADR(SelectFunction1STR),
        SelectFunction2, y.ADR(SelectFunction2STR),
        ChangeTable, y.ADR(ChangeTableSTR),
        TableDesign, y.ADR(TableDesignSTR),
        CalcRow, y.ADR(CalcRowSTR),
        SelectRowWithXValues, y.ADR(SelectRowWithXValuesSTR),
        TablePreview, y.ADR(TablePreviewSTR),
        ProcessTable, y.ADR(ProcessTableSTR),
        ColumnWidthUniformShort, y.ADR(ColumnWidthUniformShortSTR),
        SeparateFirstColumn, y.ADR(SeparateFirstColumnSTR),
        SelectFontForTable, y.ADR(SelectFontForTableSTR),
        TheTableMustContainAtLeast, y.ADR(TheTableMustContainAtLeastSTR),
        OneRowForThisFunction, y.ADR(OneRowForThisFunctionSTR),
        TwoRowsForThisFunction, y.ADR(TwoRowsForThisFunctionSTR),
        ChangeText, y.ADR(ChangeTextSTR),
        Mouse, y.ADR(MouseSTR),
        Coordinates, y.ADR(CoordinatesSTR),
        Bold, y.ADR(BoldSTR),
        Italic, y.ADR(ItalicSTR),
        Underlined, y.ADR(UnderlinedSTR),
        SnapToGraph, y.ADR(SnapToGraphSTR),
        SelectFontForText, y.ADR(SelectFontForTextSTR),
        ChangePoint, y.ADR(ChangePointSTR),
        ChangeMarker, y.ADR(ChangeMarkerSTR),
        FillPoint, y.ADR(FillPointSTR),
        MarkerDesign, y.ADR(MarkerDesignSTR),
        MarkerLegend, y.ADR(MarkerLegendSTR),
        MarkerPattern, y.ADR(MarkerPatternSTR),
        MarkerWidth, y.ADR(MarkerWidthSTR),
        TextOrientation, y.ADR(TextOrientationSTR),
        TextSide, y.ADR(TextSideSTR),
        NewEntry, y.ADR(NewEntrySTR),
        DelEntry, y.ADR(DelEntrySTR),
        AxesCoordinates, y.ADR(AxesCoordinatesSTR),
        ScreenCoordinates, y.ADR(ScreenCoordinatesSTR),
        Pattern, y.ADR(PatternSTR),
        PatternsEx, y.ADR(PatternsExSTR),
        NewPattern, y.ADR(NewPatternSTR),
        DelPattern, y.ADR(DelPatternSTR),
        TextTransparent, y.ADR(TextTransparentSTR),
        SelectFontForPoint, y.ADR(SelectFontForPointSTR),
        Of, y.ADR(OfSTR),
        CreatePoints, y.ADR(CreatePointsSTR),
        NameOfFirstPoint, y.ADR(NameOfFirstPointSTR),
        CreateMarkers, y.ADR(CreateMarkersSTR),
        NameOfFirstMarker, y.ADR(NameOfFirstMarkerSTR),
        OfFunctions, y.ADR(OfFunctionsSTR),
        OfFunction, y.ADR(OfFunctionSTR),
        XAxisDomain, y.ADR(XAxisDomainSTR),
        Abscissa, y.ADR(AbscissaSTR),
        Ordinate, y.ADR(OrdinateSTR),
        DefaultList, y.ADR(DefaultListSTR),
        CustomList, y.ADR(CustomListSTR),
        DefaultPoint, y.ADR(DefaultPointSTR),
        CustomPoint, y.ADR(CustomPointSTR),
        DefaultMarker, y.ADR(DefaultMarkerSTR),
        CustomMarker, y.ADR(CustomMarkerSTR),
        AsList, y.ADR(AsListSTR),
        AsPoints, y.ADR(AsPointsSTR),
        AsMarkers, y.ADR(AsMarkersSTR),
        ChangeVariable, y.ADR(ChangeVariableSTR),
        InThe, y.ADR(InTheSTR),
        Range, y.ADR(RangeSTR),
        FindingMaximumPoints, y.ADR(FindingMaximumPointsSTR),
        FindingMinimumPoints, y.ADR(FindingMinimumPointsSTR),
        SetVariableValues, y.ADR(SetVariableValuesSTR),
        Undefined, y.ADR(UndefinedSTR),
        LocalMaximum, y.ADR(LocalMaximumSTR),
        LocalMinimum, y.ADR(LocalMinimumSTR),
        GlobalMaximumQ, y.ADR(GlobalMaximumQSTR),
        GlobalMinimumQ, y.ADR(GlobalMinimumQSTR),
        ExtremePoints, y.ADR(ExtremePointsSTR),
        FindingZeros, y.ADR(FindingZerosSTR),
        ChangeInSign, y.ADR(ChangeInSignSTR),
        NoChangeInSign, y.ADR(NoChangeInSignSTR),
        Zeros, y.ADR(ZerosSTR),
        FindingGaps, y.ADR(FindingGapsSTR),
        DefinitionGaps, y.ADR(DefinitionGapsSTR),
        CurvatureLeftRight, y.ADR(CurvatureLeftRightSTR),
        CurvatureRightLeft, y.ADR(CurvatureRightLeftSTR),
        FindingPointsOfInflection, y.ADR(FindingPointsOfInflectionSTR),
        PointsOfInflection, y.ADR(PointsOfInflectionSTR),
        FindingIntersections, y.ADR(FindingIntersectionsSTR),
        Intersections, y.ADR(IntersectionsSTR),
        ForRange, y.ADR(ForRangeSTR),
        And, y.ADR(AndSTR),
        CompleteFunctionAnalysis, y.ADR(CompleteFunctionAnalysisSTR),
        Print, y.ADR(PrintSTR),
        TextBox, y.ADR(TextBoxSTR),
        AnalysisOfFunction, y.ADR(AnalysisOfFunctionSTR),
        Derivatives, y.ADR(DerivativesSTR),
        NoSimpleSymmetryFound, y.ADR(NoSimpleSymmetryFoundSTR),
        AxialSymmetryToYAxis, y.ADR(AxialSymmetryToYAxisSTR),
        PointSymmetryToOrigin, y.ADR(PointSymmetryToOriginSTR),
        NoZerosFound, y.ADR(NoZerosFoundSTR),
        NoExtremePointsFound, y.ADR(NoExtremePointsFoundSTR),
        NoPointsOfInflectionFound, y.ADR(NoPointsOfInflectionFoundSTR),
        Symmetry, y.ADR(SymmetrySTR),
        create, y.ADR(createSTR),
        MaxDegree, y.ADR(MaxDegreeSTR),
        search, y.ADR(searchSTR),
        MaximumPoint, y.ADR(MaximumPointSTR),
        MinimumPoint, y.ADR(MinimumPointSTR),
        NoElementSelected, y.ADR(NoElementSelectedSTR),
        AboveXAxis, y.ADR(AboveXAxisSTR),
        BelowXAxis, y.ADR(BelowXAxisSTR),
        RightOfYAxis, y.ADR(RightOfYAxisSTR),
        LeftOfYAxis, y.ADR(LeftOfYAxisSTR),
        RightOfXValue, y.ADR(RightOfXValueSTR),
        LeftOfXValue, y.ADR(LeftOfXValueSTR),
        AboveYValue, y.ADR(AboveYValueSTR),
        BelowYValue, y.ADR(BelowYValueSTR),
        AboveFunction, y.ADR(AboveFunctionSTR),
        BelowFunction, y.ADR(BelowFunctionSTR),
        RightAboveP, y.ADR(RightAbovePSTR),
        LeftAboveP, y.ADR(LeftAbovePSTR),
        RightBelowP, y.ADR(RightBelowPSTR),
        LeftBelowP, y.ADR(LeftBelowPSTR),
        RightOfMarker, y.ADR(RightOfMarkerSTR),
        LeftOfMarker, y.ADR(LeftOfMarkerSTR),
        ChangeHatching, y.ADR(ChangeHatchingSTR),
        NewElement, y.ADR(NewElementSTR),
        DelElement, y.ADR(DelElementSTR),
        HatchingBounds, y.ADR(HatchingBoundsSTR),
        HatchingDesign, y.ADR(HatchingDesignSTR),
        BoundaryElements, y.ADR(BoundaryElementsSTR),
        CurrentElement, y.ADR(CurrentElementSTR),
        XAxis, y.ADR(XAxisSTR),
        YAxis, y.ADR(YAxisSTR),
        XValue, y.ADR(XValueSTR),
        YValue, y.ADR(YValueSTR),
        HatchingName, y.ADR(HatchingNameSTR),
        ClearBackground, y.ADR(ClearBackgroundSTR),
        HatchingToTheBack, y.ADR(HatchingToTheBackSTR),
        ElementsEx, y.ADR(ElementsExSTR),
        SelectPoint, y.ADR(SelectPointSTR),
        SelectMarker, y.ADR(SelectMarkerSTR),
        Calculate, y.ADR(CalculateSTR),
        DefaultHatching, y.ADR(DefaultHatchingSTR),
        CustomHatching, y.ADR(CustomHatchingSTR),
        SurfaceBetweenFunctions, y.ADR(SurfaceBetweenFunctionsSTR),
        HatchSurface, y.ADR(HatchSurfaceSTR),
        From, y.ADR(FromSTR),
        To, y.ADR(ToSTR),
        ResultDP, y.ADR(ResultDPSTR),
        Absolute, y.ADR(AbsoluteSTR),
        Oriented, y.ADR(OrientedSTR),
        Rotation, y.ADR(RotationSTR),
        Below, y.ADR(BelowSTR),
        Above, y.ADR(AboveSTR),
        LowerLimit, y.ADR(LowerLimitSTR),
        UpperLimit, y.ADR(UpperLimitSTR),
        TheUpperLimitMustBe, y.ADR(TheUpperLimitMustBeSTR),
        HigherThanTheLowerLimit, y.ADR(HigherThanTheLowerLimitSTR),
        ItCannotBeIntegrated, y.ADR(ItCannotBeIntegratedSTR),
        OverADefinitionGap, y.ADR(OverADefinitionGapSTR),
        ChangeZoom, y.ADR(ChangeZoomSTR),
        ZoomInPerCent, y.ADR(ZoomInPerCentSTR),
        ChangeRasterGrid, y.ADR(ChangeRasterGridSTR),
        DisplayRasterGrid, y.ADR(DisplayRasterGridSTR),
        Snap, y.ADR(SnapSTR),
        AdaptBoxSize, y.ADR(AdaptBoxSizeSTR),
        units, y.ADR(unitsSTR),
        cm, y.ADR(cmSTR),
        ChangeBox, y.ADR(ChangeBoxSTR),
        BoxCoordinates, y.ADR(BoxCoordinatesSTR),
        Position, y.ADR(PositionSTR),
        Dimensions, y.ADR(DimensionsSTR),
        BoxParameters, y.ADR(BoxParametersSTR),
        Left, y.ADR(LeftSTR),
        Right, y.ADR(RightSTR),
        Top, y.ADR(TopSTR),
        LockBox, y.ADR(LockBoxSTR),
        DisplayBoxFast, y.ADR(DisplayBoxFastSTR),
        GlobalPageSettings, y.ADR(GlobalPageSettingsSTR),
        PageDimensions, y.ADR(PageDimensionsSTR),
        Defaults, y.ADR(DefaultsSTR),
        custom, y.ADR(customSTR),
        CouldntLoadFont1, y.ADR(CouldntLoadFont1STR),
        CouldntLoadFont2, y.ADR(CouldntLoadFont2STR),
        SelectFont, y.ADR(SelectFontSTR),
        Selection, y.ADR(SelectionSTR),
        Size, y.ADR(SizeSTR),
        UseAutoFont, y.ADR(UseAutoFontSTR),
        FontsEx, y.ADR(FontsExSTR),
        FontConversion, y.ADR(FontConversionSTR),
        NewFont, y.ADR(NewFontSTR),
        DelFont, y.ADR(DelFontSTR),
        MathModeFont, y.ADR(MathModeFontSTR),
        LayoutModeFont, y.ADR(LayoutModeFontSTR),
        MathModeSize, y.ADR(MathModeSizeSTR),
        LayoutModeSize, y.ADR(LayoutModeSizeSTR),
        Pixels, y.ADR(PixelsSTR),
        PicaPoints, y.ADR(PicaPointsSTR),
        NoColorsEntered1, y.ADR(NoColorsEntered1STR),
        NoColorsEntered2, y.ADR(NoColorsEntered2STR),
        ChangeColors, y.ADR(ChangeColorsSTR),
        NewColor, y.ADR(NewColorSTR),
        DelColor, y.ADR(DelColorSTR),
        CurrentColor, y.ADR(CurrentColorSTR),
        SelectColor, y.ADR(SelectColorSTR),
        ColorwheelNotAvailable1, y.ADR(ColorwheelNotAvailable1STR),
        ColorwheelNotAvailable2, y.ADR(ColorwheelNotAvailable2STR),
        ColorsEx, y.ADR(ColorsExSTR),
        White, y.ADR(WhiteSTR),
        Hair, y.ADR(HairSTR),
        ChangeTextLine, y.ADR(ChangeTextLineSTR),
        TextLine, y.ADR(TextLineSTR),
        TextInput, y.ADR(TextInputSTR),
        FillUp, y.ADR(FillUpSTR),
        SelectTextColor, y.ADR(SelectTextColorSTR),
        TextColor, y.ADR(TextColorSTR),
        SelectBackgroundColor, y.ADR(SelectBackgroundColorSTR),
        ChangeGraphic, y.ADR(ChangeGraphicSTR),
        Ellipse, y.ADR(EllipseSTR),
        Rectangle, y.ADR(RectangleSTR),
        LayoutLine, y.ADR(LayoutLineSTR),
        OutlineColor, y.ADR(OutlineColorSTR),
        FillColor, y.ADR(FillColorSTR),
        LineColor, y.ADR(LineColorSTR),
        SelectOutlineColor, y.ADR(SelectOutlineColorSTR),
        SelectFillColor, y.ADR(SelectFillColorSTR),
        ColorConversion, y.ADR(ColorConversionSTR),
        MathModeColor, y.ADR(MathModeColorSTR),
        DocumentColor, y.ADR(DocumentColorSTR),
        SelectDocumentColor, y.ADR(SelectDocumentColorSTR),
        LineThicknessConversion, y.ADR(LineThicknessConversionSTR),
        MathModeThickness, y.ADR(MathModeThicknessSTR),
        PrintThickness, y.ADR(PrintThicknessSTR),
        AxisSystemConversion, y.ADR(AxisSystemConversionSTR),
        AxisSystemColor, y.ADR(AxisSystemColorSTR),
        SelectAxisSystemColor, y.ADR(SelectAxisSystemColorSTR),
        BackgroundGridConversion, y.ADR(BackgroundGridConversionSTR),
        SelectGridColor, y.ADR(SelectGridColorSTR),
        GridColor, y.ADR(GridColorSTR),
        ChangeBoxContents, y.ADR(ChangeBoxContentsSTR),
        AxisSystem, y.ADR(AxisSystemSTR),
        BackgroundGrid, y.ADR(BackgroundGridSTR),
        BoxContents, y.ADR(BoxContentsSTR),
        GraphicColor, y.ADR(GraphicColorSTR),
        SelectGraphicColor, y.ADR(SelectGraphicColorSTR),
        LayoutWorkingWindowTitle, y.ADR(LayoutWorkingWindowTitleSTR),
        LayoutWorkingScreenTitle, y.ADR(LayoutWorkingScreenTitleSTR),
        PrintingPage, y.ADR(PrintingPageSTR),
        SelectASCIIFile, y.ADR(SelectASCIIFileSTR),
        CouldntOpenFile1, y.ADR(CouldntOpenFile1STR),
        CouldntOpenFile2, y.ADR(CouldntOpenFile2STR),
        ChangeFormula, y.ADR(ChangeFormulaSTR),
        Formula, y.ADR(FormulaSTR),
        PrinterSettings, y.ADR(PrinterSettingsSTR),
        QualityPrintout, y.ADR(QualityPrintoutSTR),
        DraftPrintout, y.ADR(DraftPrintoutSTR),
        Portrait, y.ADR(PortraitSTR),
        Landscape, y.ADR(LandscapeSTR),
        ResolutionPrinter, y.ADR(ResolutionPrinterSTR),
        GrayScaleRastering, y.ADR(GrayScaleRasteringSTR),
        ColorCorrection, y.ADR(ColorCorrectionSTR),
        NumberGraySteps, y.ADR(NumberGrayStepsSTR),
        Driver, y.ADR(DriverSTR),
        BlackAndWhite, y.ADR(BlackAndWhiteSTR),
        GrayScale, y.ADR(GrayScaleSTR),
        Ordered, y.ADR(OrderedSTR),
        Halftone, y.ADR(HalftoneSTR),
        FloydSteinberg, y.ADR(FloydSteinbergSTR),
        Fonts, y.ADR(FontsSTR),
        SortFonts, y.ADR(SortFontsSTR),
        NewPath, y.ADR(NewPathSTR),
        DelPath, y.ADR(DelPathSTR),
        PathCurrentFont, y.ADR(PathCurrentFontSTR),
        PathsEx, y.ADR(PathsExSTR),
        ScreenPresentation, y.ADR(ScreenPresentationSTR),
        MaximumDistortionInPerCent, y.ADR(MaximumDistortionInPerCentSTR),
        QuitLayout, y.ADR(QuitLayoutSTR),
        SetTextbox, y.ADR(SetTextboxSTR),
        SetTextline, y.ADR(SetTextlineSTR),
        DrawLine, y.ADR(DrawLineSTR),
        SetRectangle, y.ADR(SetRectangleSTR),
        SetEllipse, y.ADR(SetEllipseSTR),
        Work, y.ADR(WorkSTR),
        DeleteActiveBox, y.ADR(DeleteActiveBoxSTR),
        ChangeActiveBox, y.ADR(ChangeActiveBoxSTR),
        Script, y.ADR(ScriptSTR),
        Style, y.ADR(StyleSTR),
        Alignment, y.ADR(AlignmentSTR),
        Center, y.ADR(CenterSTR),
        Justify, y.ADR(JustifySTR),
        ImportASCII, y.ADR(ImportASCIISTR),
        InsertFormula, y.ADR(InsertFormulaSTR),
        Conversion, y.ADR(ConversionSTR),
        Preferences, y.ADR(PreferencesSTR),
        Zoom, y.ADR(ZoomSTR),
        RasterGrid, y.ADR(RasterGridSTR),
        DocumentColors, y.ADR(DocumentColorsSTR),
        ShowInactive, y.ADR(ShowInactiveSTR),
        ToolBox, y.ADR(ToolBoxSTR),
        CustomScreen, y.ADR(CustomScreenSTR),
        Printing, y.ADR(PrintingSTR),
        AbortPrintout, y.ADR(AbortPrintoutSTR),
        ScalingFonts, y.ADR(ScalingFontsSTR),
        RequestingPrintoutMemory, y.ADR(RequestingPrintoutMemorySTR),
        ReallyAbortPrintout1, y.ADR(ReallyAbortPrintout1STR),
        ReallyAbortPrintout2, y.ADR(ReallyAbortPrintout2STR),
        FunctionOnlyOnFunctionBoxes1, y.ADR(FunctionOnlyOnFunctionBoxes1STR),
        FunctionOnlyOnFunctionBoxes2, y.ADR(FunctionOnlyOnFunctionBoxes2STR),
        Page, y.ADR(PageSTR),
        rest, y.ADR(restSTR),
        Cyan, y.ADR(CyanSTR),
        Magenta, y.ADR(MagentaSTR),
        Yellow, y.ADR(YellowSTR),
        Black, y.ADR(BlackSTR),
        Gray, y.ADR(GraySTR),
        Red, y.ADR(RedSTR),
        Green, y.ADR(GreenSTR),
        Blue, y.ADR(BlueSTR),
        AllRightsReserved, y.ADR(AllRightsReservedSTR),
        ThisIsADemo1, y.ADR(ThisIsADemo1STR),
        ThisIsADemo2, y.ADR(ThisIsADemo2STR),
        ThisVersionIsRegisteredTo, y.ADR(ThisVersionIsRegisteredToSTR),
        WindowMustContain2Functions1, y.ADR(WindowMustContain2Functions1STR),
        WindowMustContain2Functions2, y.ADR(WindowMustContain2Functions2STR),
        LoadDocument, y.ADR(LoadDocumentSTR),
        SaveDocument, y.ADR(SaveDocumentSTR),
        LoadConfiguration, y.ADR(LoadConfigurationSTR),
        SaveConfiguration, y.ADR(SaveConfigurationSTR),
        FileAlreadyExists, y.ADR(FileAlreadyExistsSTR),
        Overwrite, y.ADR(OverwriteSTR),
        CouldntLoadFileDP, y.ADR(CouldntLoadFileDPSTR),
        VersionTooLate, y.ADR(VersionTooLateSTR),
        ChecksumError, y.ADR(ChecksumErrorSTR),
        NoValidAnalayConfigurationFile1, y.ADR(NoValidAnalayConfigurationFile1STR),
        NoValidAnalayConfigurationFile2, y.ADR(NoValidAnalayConfigurationFile2STR),
        NoValidAnalayDocumentFile1, y.ADR(NoValidAnalayDocumentFile1STR),
        NoValidAnalayDocumentFile2, y.ADR(NoValidAnalayDocumentFile2STR),
        PIName, y.ADR(PINameSTR),
        EulerName, y.ADR(EulerNameSTR),
        PlanckName, y.ADR(PlanckNameSTR),
        LightSpeedName, y.ADR(LightSpeedNameSTR),
        ElementaryChargeName, y.ADR(ElementaryChargeNameSTR),
        ElectronMassName, y.ADR(ElectronMassNameSTR),
        NeutronMassName, y.ADR(NeutronMassNameSTR),
        ProtonMassName, y.ADR(ProtonMassNameSTR),
        AtomicMassUnitName, y.ADR(AtomicMassUnitNameSTR),
        MolarVolumeIdealGasName, y.ADR(MolarVolumeIdealGasNameSTR),
        AvogadroName, y.ADR(AvogadroNameSTR),
        GravitationName, y.ADR(GravitationNameSTR),
        MolarGasConstantName, y.ADR(MolarGasConstantNameSTR),
        NormalPressureName, y.ADR(NormalPressureNameSTR),
        BoltzmannName, y.ADR(BoltzmannNameSTR),
        PermittivityName, y.ADR(PermittivityNameSTR),
        PermeabilityName, y.ADR(PermeabilityNameSTR)
      );

VAR locale  * : lo.LocalePtr;
    catalog * : lo.CatalogPtr;

PROCEDURE CloseCatalog*();

BEGIN
  IF catalog#NIL THEN
    lo.CloseCatalog(catalog);
    catalog:=NIL;
  END;
END CloseCatalog;

PROCEDURE OpenCatalog*(loc:lo.LocalePtr; language:ARRAY OF CHAR);

VAR Tag : u.Tags4;

BEGIN
  CloseCatalog();
  IF (catalog = NIL) & (lo.base # NIL) THEN
    Tag:= u.Tags4(lo.builtInLanguage, y.ADR(builtinlanguage),
                  u.skip, u.done, lo.version, version, u.done, u.done);
    IF language # "" THEN
      Tag[1].tag:= lo.language; Tag[1].data:= y.ADR(language);
    END;
    catalog := lo.OpenCatalogA (loc, "Analay.catalog", Tag);
  END;
END OpenCatalog;

PROCEDURE GetString*(num:LONGINT):e.STRPTR;

VAR i       : LONGINT;
    default : e.STRPTR;

BEGIN
  i:=num;
  IF i<636 THEN
    IF AppStrings[i].id#num THEN
      i:=0;
      WHILE (i<636) AND (AppStrings[i].id#num) DO
        INC(i)
      END;
    END;
  ELSE
    i:=636;
  END;

  IF i#636 THEN
    default:=AppStrings[i].str;
  ELSE
    default:=NIL;
  END;

  IF catalog#NIL THEN
    RETURN lo.GetCatalogStr(catalog,num,default^);
  ELSE
    RETURN default;
  END;
END GetString;

BEGIN
  IF lo.base#NIL THEN
    locale:=lo.OpenLocale(NIL);
  ELSE
    locale:=NIL;
  END;
  IF locale#NIL THEN
    OpenCatalog(NIL,"");
  END;
CLOSE
  CloseCatalog();
  IF locale#NIL THEN           (* Could cause problems (Why?). *)
    lo.CloseLocale(locale);
  END;
END AnalayCatalog.
