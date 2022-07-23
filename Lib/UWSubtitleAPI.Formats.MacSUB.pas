{*
 *  URUWorks Subtitle API
 *
 *  The contents of this file are used with permission, subject to
 *  the Mozilla Public License Version 1.1 (the "License"); you may
 *  not use this file except in compliance with the License. You may
 *  obtain a copy of the License at
 *  http://www.mozilla.org/MPL/MPL-1.1.html
 *
 *  Software distributed under the License is distributed on an
 *  "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 *  implied. See the License for the specific language governing
 *  rights and limitations under the License.
 *
 *  Copyright (C) 2001-2022 URUWorks, uruworks@gmail.com.
 *
 *}

unit UWSubtitleAPI.Formats.MacSUB;

// -----------------------------------------------------------------------------

interface

uses
  SysUtils, UWSubtitleAPI, UWSystem.TimeUtils, UWSystem.SysUtils,
  UWSubtitleAPI.Formats;

type

  { TUWMacSUB }

  TUWMacSUB = class(TUWSubtitleCustomFormat)
  public
    function Name: String; override;
    function Format: TUWSubtitleFormats; override;
    function Extension: String; override;
    function IsTimeBased: Boolean; override;
    function HasStyleSupport: Boolean; override;
    function IsMine(const SubtitleFile: TUWStringList; const Row: Integer): Boolean; override;
    function LoadSubtitle(const SubtitleFile: TUWStringList; const FPS: Single; var Subtitles: TUWSubtitles): Boolean; override;
    function SaveSubtitle(const FileName: String; const FPS: Single; const Encoding: TEncoding; const Subtitles: TUWSubtitles; const FromItem: Integer = -1; const ToItem: Integer = -1): Boolean; override;
    function ToText(const Subtitles: TUWSubtitles): String; override;
  end;

// -----------------------------------------------------------------------------

implementation

uses UWSubtitleAPI.ExtraInfo, UWSubtitleAPI.Tags;

// -----------------------------------------------------------------------------

function TUWMacSUB.Name: String;
begin
  Result := IndexToName(Integer(Format));
end;

// -----------------------------------------------------------------------------

function TUWMacSUB.Format: TUWSubtitleFormats;
begin
  Result := TUWSubtitleFormats.sfMacSUB;
end;

// -----------------------------------------------------------------------------

function TUWMacSUB.Extension: String;
begin
  Result := '*.scr';
end;

// -----------------------------------------------------------------------------

function TUWMacSUB.IsTimeBased: Boolean;
begin
  Result := False;
end;

// -----------------------------------------------------------------------------

function TUWMacSUB.HasStyleSupport: Boolean;
begin
  Result := False;
end;

// -----------------------------------------------------------------------------

function TUWMacSUB.IsMine(const SubtitleFile: TUWStringList; const Row: Integer): Boolean;
begin
  if (Pos('/', SubtitleFile[Row]) = 1) and
     (IsInteger(Copy(SubtitleFile[Row], 2, Length(SubtitleFile[Row])))) then
    Result := True
  else
    Result := False;
end;

// -----------------------------------------------------------------------------

function TUWMacSUB.LoadSubtitle(const SubtitleFile: TUWStringList; const FPS: Single; var Subtitles: TUWSubtitles): Boolean;
var
  i, c        : Integer;
  InitialTime : Integer;
  FinalTime   : Integer;
  Text        : String;
begin
  Result := False;
  try
    for i := 0 to SubtitleFile.Count-1 do
    begin
      if (Pos('/', SubtitleFile[i]) = 1) and
         (IsInteger(Copy(SubtitleFile[i], 2, Length(SubtitleFile[i])))) then
      begin
        InitialTime := FramesToTime(StrToInt(Copy(SubtitleFile[i], 2, Length(SubtitleFile[i]))), FPS);
        c    := 1;
        Text := '';
        while (i+c <= (SubtitleFile.Count-1)) and (Pos('/', SubtitleFile[i+c]) <> 1) do
        begin
          If Text <> '' then
            Text := Text + LineEnding + SubtitleFile[i+c]
          else
            Text := SubtitleFile[i+c];
          Inc(c);
        end;

        if (i+c <= (SubtitleFile.Count-1)) and (IsInteger(Copy(SubtitleFile[i+c], 2, Length(SubtitleFile[i+c])))) then
          FinalTime := FramesToTime(StrToInt(Copy(SubtitleFile[i+c], 2, Length(SubtitleFile[i+c]))), FPS)
        else
          FinalTime := InitialTime + 2000;

        if (InitialTime > -1) and (FinalTime > -1) then
          Subtitles.Add(InitialTime, FinalTime, Text, '');
      end;
    end;
  finally
    Result := Subtitles.Count > 0;
  end;
end;

// -----------------------------------------------------------------------------

function TUWMacSUB.SaveSubtitle(const FileName: String; const FPS: Single; const Encoding: TEncoding; const Subtitles: TUWSubtitles; const FromItem: Integer = -1; const ToItem: Integer = -1): Boolean;
var
  SubFile : TUWStringList;
  i       : Integer;
begin
  Result  := False;
  SubFile := TUWStringList.Create;
  try
    for i := FromItem to ToItem do
    begin
      Subtitles.Text[i] := RemoveSWTags(Subtitles.Text[i]);
      SubFile.Add('/' + IntToStr(TimeToFrames(Subtitles[i].InitialTime, FPS)), False);
      SubFile.Add(Subtitles[i].Text, False);
      SubFile.Add('/' + IntToStr(TimeToFrames(Subtitles[i].FinalTime, FPS)), False);
    end;

    try
      SubFile.SaveToFile(FileName, Encoding);
      Result := True;
    except
    end;
  finally
    SubFile.Free;
  end;
end;

// -----------------------------------------------------------------------------

function TUWMacSUB.ToText(const Subtitles: TUWSubtitles): String;
begin
  Result := '';
end;

// -----------------------------------------------------------------------------

end.
