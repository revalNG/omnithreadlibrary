unit TestBlockingCollection1;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, GpStuff, Windows, DSiWin32, OtlContainers, SysUtils,
  OtlContainerObserver, OtlCollections, OtlCommon, OtlSync;

type
  // Test methods for class IOmniBlockingCollection
  TestIOmniBlockingCollection = class(TTestCase)
  published
    procedure TestCompleteAdding;
  end;

implementation

uses
  OtlParallel;

procedure TestIOmniBlockingCollection.TestCompleteAdding;
var
  coll     : IOmniBlockingCollection;
  iTest    : integer;
  lastAdded: integer;
  lastRead : TOmniValue;
begin
  for iTest := 1 to 1000 do begin
    coll := TOmniBlockingCollection.Create;
    lastAdded := -1;
    lastRead := -2;
    Parallel.Join([
      procedure
      var
        i: integer;
      begin
        for i := 1 to 100000 do begin
          if not coll.TryAdd(i) then
            break;
          lastAdded := i;
        end;
      end,

      procedure
      begin
        Sleep(1);
        coll.CompleteAdding;
      end,

      procedure
      begin
        while coll.TryTake(lastRead, INFINITE) do
          ;
      end
    ]).Execute;
    if (lastAdded > 0) and (lastRead.AsInteger > 0) and (lastAdded <> lastRead.AsInteger) then
      break; //for iTest
  end;
  CheckEquals(lastAdded, lastRead.AsInteger);
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestIOmniBlockingCollection.Suite);
end.
