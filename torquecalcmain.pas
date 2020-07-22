unit TorqueCalcMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TTorqueCalcForm }

  TTorqueCalcForm = class(TForm)
    CalculateButton: TButton;
    MetricCheckBox: TCheckBox;
    ReductionNumEdit: TEdit;
    Label20: TLabel;
    SpeedEdit: TEdit;
    AccelGEdit: TEdit;
    AccelEdit: TEdit;
    RadiusLabel: TLabel;
    CLinForceLabel: TLabel;
    PLinForceLabel: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    SpeedLabel: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    AccelLabel: TLabel;
    LSRadiusEdit: TEdit;
    CLinForceEdit: TEdit;
    PLinForceEdit: TEdit;
    GroupBox3: TGroupBox;
    Label10: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PitchLabel: TLabel;
    WeightLabel: TLabel;
    Label7: TLabel;
    CTorqueLabel: TLabel;
    PTorqueLabel: TLabel;
    LeadScrewPitchEdit: TEdit;
    ReductionDenomEdit: TEdit;
    WeightEdit: TEdit;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    RPMEdit: TEdit;
    CTorqueEdit: TEdit;
    PTorqueEdit: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure CalculateButtonClick(Sender: TObject);
    procedure MetricCheckBoxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RadiusLabelClick(Sender: TObject);
  private

  public
    LSRadius, CForce, PForce : real;
    Weight, AccelerationG : real;
    ReductionRatio, ReductionNum, ReductionDenom : real;
    RPM, SpeedIPM : real;
    LeadScrewPitch : real;
    Gravity : real;  // Holds either 9.81m/s^2 or 384 in/s^2
  end;

var
  TorqueCalcForm: TTorqueCalcForm;

implementation

{$R *.lfm}

{ TTorqueCalcForm }

{
  From Jon Elson <elson@pico-systems.com>
    So, if you had a drum with a
    string wrapped around it that advanced the
    axis as much as the leadscrew, it should be equivalent
    (ignoring friction and diameter of the string).  So, how big
    would such a drum be?  The circumference should be equal to
    the pitch of the screw, in this case 0.2".  So, what is the
    radius of a circle with a 0.2" circumference?  2 Pi R =
    Circumf. so
    R = circumf./2 Pi   so, 0.2 / (2 Pi) = 0.0318
    --- R becomes LSRadius.
}
procedure TTorqueCalcForm.CalculateButtonClick(Sender: TObject);
begin
  if  MetricCheckBox.Checked then begin  // Metric Calculations.
     // Calculate Lead Screw Radius
     LeadScrewPitch := StrToFloat(LeadscrewPitchEdit.Text);
     LSRadius := LeadscrewPitch/(2 * PI);
     LSRadiusEdit.text := FloatToStrF(LSRadius, ffFixed, 7, 4);
     //
     ReductionDenom := StrToFloat(ReductionDenomEdit.text);
     if ReductionDenom <= 0 then
        ReductionDenom := 1;
     ReductionNum := StrToFloat(ReductionNumEdit.text);
     if ReductionNum <= 0 then
        ReductionNum := 1;
     ReductionRatio := ReductionNum/ReductionDenom;
     CForce := StrToFloat(CTorqueEdit.Text)/16/LSRadius/ReductionRatio;
     CLinForceEdit.Text :=  FloatToStrF(CForce,ffFixed, 5, 1 );
     PForce := StrToFloat(PTorqueEdit.Text)/16/LSRadius/ReductionRatio;
     PLinForceEdit.Text :=  FloatToStrF(PForce,ffFixed, 5, 1 );
     RPM := StrToFloat(RPMEdit.Text);
     SpeedIPM := LeadscrewPitch * RPM * ReductionRatio;
     SpeedEdit.Text := FloatToStrF(SpeedIPM,ffFixed, 5, 1 );
     Weight := StrToFloat(WeightEdit.Text);
     if weight <= 0 then
        weight := 1;
     AccelerationG := (CForce / Weight);
     AccelGEdit.text := FloatToStrF(AccelerationG,ffFixed, 4, 2 );
     AccelEdit.text := FloatToStrF(AccelerationG * Gravity,ffFixed, 4, 2 );
  end
  else begin   // Imperial Calculations.
    // Calculate Lead Screw Radius
    LeadScrewPitch := StrToFloat(LeadscrewPitchEdit.Text);
    LSRadius := LeadscrewPitch/(2 * PI);
    LSRadiusEdit.text := FloatToStrF(LSRadius, ffFixed, 7, 4);
    //
    ReductionDenom := StrToFloat(ReductionDenomEdit.text);
    if ReductionDenom <= 0 then
       ReductionDenom := 1;
    ReductionNum := StrToFloat(ReductionNumEdit.text);
    if ReductionNum <= 0 then
       ReductionNum := 1;
    ReductionRatio := ReductionNum/ReductionDenom;
    CForce := StrToFloat(CTorqueEdit.Text)/16/LSRadius/ReductionRatio;
    CLinForceEdit.Text :=  FloatToStrF(CForce,ffFixed, 5, 1 );
    PForce := StrToFloat(PTorqueEdit.Text)/16/LSRadius/ReductionRatio;
    PLinForceEdit.Text :=  FloatToStrF(PForce,ffFixed, 5, 1 );
    RPM := StrToFloat(RPMEdit.Text);
    SpeedIPM := LeadscrewPitch * RPM * ReductionRatio;
    SpeedEdit.Text := FloatToStrF(SpeedIPM,ffFixed, 5, 1 );
    Weight := StrToFloat(WeightEdit.Text);
    if weight <= 0 then
       weight := 1;
    AccelerationG := (CForce / Weight);
    AccelGEdit.text := FloatToStrF(AccelerationG,ffFixed, 4, 2 );
    AccelEdit.text := FloatToStrF(AccelerationG * Gravity,ffFixed, 4, 2 );
  end;
end;


{
  Change all EDIT fields and Info Field labels to show metric units.
  Convert all fields between imperial and Metric
}
procedure TTorqueCalcForm.MetricCheckBoxChange(Sender: TObject);
begin
  if  MetricCheckBox.Checked then begin
    CTorqueLabel.Caption := 'Nm';
    PTorqueLabel.Caption := 'Nm';

    PitchLabel.Caption := 'mm';
    LeadScrewPitchEdit.Text := FloatToStrF(
                            (StrToFloat(LeadscrewPitchEdit.text) * 25.4),ffFixed, 6,2 );

    WeightLabel.Caption := 'kg';
    WeightEdit.Text := FloatToStrF(
                            (StrToFloat(WeightEdit.text) / 2.2),ffFixed, 6,2 );

    RadiusLabel.Caption := 'mm';
    LSRadiusEdit.Text := FloatToStrF(
                            (StrToFloat(LSRadiusEdit.text) * 25.4),ffFixed, 6,2 );

    CLinForceLabel.Caption := 'kg';
    CLinForceEdit.Text := FloatToStrF(
                            (StrToFloat(CLinForceEdit.text) / 2.2),ffFixed, 6,2 );

    PLinForceLabel.Caption := 'kg';
    PLinForceEdit.Text := FloatToStrF(
                            (StrToFloat(PLinForceEdit.text) / 2.2),ffFixed, 6,2 );

    SpeedLabel.Caption := 'mm/min';
    SpeedEdit.Text := FloatToStrF(
                            (StrToFloat(SpeedEdit.text) * 25.4),ffFixed, 6,4 );
    AccelLabel.Caption := 'mm/sec^2';
    AccelEdit.Text := FloatToStrF(
                            (StrToFloat(AccelEdit.text) * 25.4),ffFixed, 6,4 );
  end
  else begin
    CTorqueLabel.Caption := 'oz-in';
    PTorqueLabel.Caption := 'oz-in';
    PitchLabel.Caption := 'inches';
    LeadScrewPitchEdit.Text := FloatToStrF(
                            (StrToFloat(LeadscrewPitchEdit.text) / 25.4),ffFixed, 6,2 );

    WeightLabel.Caption := 'lbs';
    WeightEdit.Text := FloatToStrF(
                            (StrToFloat(WeightEdit.text) * 2.2),ffFixed, 6,2 );

    RadiusLabel.Caption := 'inches';
    LSRadiusEdit.Text := FloatToStrF(
                            (StrToFloat(LSRadiusEdit.text) / 25.4),ffFixed, 6,4 );

    CLinForceLabel.Caption := 'lbs';
    CLinForceEdit.Text := FloatToStrF(
                            (StrToFloat(CLinForceEdit.text) * 2.2),ffFixed, 6,2 );

    PLinForceLabel.Caption := 'lbs';
    PLinForceEdit.Text := FloatToStrF(
                            (StrToFloat(PLinForceEdit.text) * 2.2),ffFixed, 6,2 );

    SpeedLabel.Caption := 'in/min';
    SpeedEdit.Text := FloatToStrF(
                            (StrToFloat(SpeedEdit.text) / 25.4),ffFixed, 6,4 );

    AccelLabel.Caption := 'in/sec^2';
    AccelEdit.Text := FloatToStrF(
                            (StrToFloat(AccelEdit.text) / 25.4),ffFixed, 6,4 );

  end;

end;

procedure TTorqueCalcForm.FormCreate(Sender: TObject);
begin
  if  MetricCheckBox.Checked then
    Gravity := 98100  // ImpeMetricrial value of gravity constant mm/sec^2
  else
    Gravity := 384  // Imperial value of gravity constant in/sec^2
end;

procedure TTorqueCalcForm.RadiusLabelClick(Sender: TObject);
begin

end;

end.

