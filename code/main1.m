function varargout = main1(varargin)
% MAIN1 MATLAB code for main1.fig
%      MAIN1, by itself, creates a new MAIN1 or raises the existing
%      singleton*.
%
%      H = MAIN1 returns the handle to a new MAIN1 or the handle to
%      the existing singleton*.
%
%      MAIN1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN1.M with the given input arguments.
%
%      MAIN1('Property','Value',...) creates a new MAIN1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main1



% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main1_OpeningFcn, ...
                   'gui_OutputFcn',  @main1_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before main1 is made visible.
function main1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main1 (see VARARGIN)

% Choose default command line output for main1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in testingg.
function testingg_Callback(hObject, eventdata, handles)
% hObject    handle to testingg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('*************** Testing the network *****************')
X_test=handles.X_test;
Y_test=handles.Y_test;
Mdl=handles.Mdl;
Y_pred = predict(Mdl, X_test);
handles.Y_test=Y_test;
handles.Y_pred=Y_pred;
helpdlg('Tested');
guidata(hObject, handles);

% --- Executes on button press in outcomes.
function outcomes_Callback(hObject, eventdata, handles)
% hObject    handle to outcomes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('*************** Result *****************')
Y_test=handles.Y_test;
Y_pred=handles.Y_pred;
accuracy = sum(Y_pred == Y_test) / length(Y_test) * 100;
disp(['Accuracy: ', num2str(accuracy), '%']);

confMat = confusionmat(Y_test, Y_pred);


precision = diag(confMat) ./ sum(confMat, 2);
recall = diag(confMat) ./ sum(confMat, 1)';

fprintf('Precision for each class:\n');
disp(precision);
fprintf('Recall for each class:\n');
disp(recall);
figure(10);
confusionchart(Y_test, Y_pred);
title('Confusion matrix'); 
helpdlg('Results are shown');
guidata(hObject, handles);


% --- Executes on button press in attributeextract.
function attributeextract_Callback(hObject, eventdata, handles)
% hObject    handle to attributeextract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('*************** Extracting features*****************')
imds=handles.imds;
labl=handles.labl;
features=[];
labls=[];
nn=length(labl);
for j=1:nn
    img=imread(imds.Files{j,1});
    [~,~,p]=size(img);
      if (p==3)
          img1=rgb2gray(img);
      else
          img1=img;
      end
      img1=double(img1);
      hogf(j,:)=extractHOGFeatures(img1);
      lbpf(j,:)=extractLBPFeatures(img1);
      fusedf=[hogf,lbpf];
      featuress=[features;fusedf];
      labls=[labls;labl(j)];
end
handles.imds=imds;
handles.labl=labl;
handles.featuress=featuress;
handles.labls=labls;
helpdlg('Features are extracted');
guidata(hObject, handles);

% --- Executes on button press in attioptimi.
function attioptimi_Callback(hObject, eventdata, handles)
% hObject    handle to attioptimi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('*************** Optimizing features*****************')
featuress=handles.featuress;
labls=handles.labls;
numIndividuals = 50; 
numGenerations = 10; 
bestFeatures = mcgpopti(featuress, labls, numIndividuals, numGenerations);
handles.bestFeatures=bestFeatures;
handles.labls=labls;
helpdlg('Features are optimized');
guidata(hObject, handles);


% --- Executes on button press in classtr.
function classtr_Callback(hObject, eventdata, handles)
% hObject    handle to classtr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('*************** Training the network *****************')
bestFeatures=handles.bestFeatures;
labls=handles.labls;
X=bestFeatures;
Y=labls;
cv = cvpartition(Y, 'Holdout', 0.2);
X_train = X(cv.training, :);
Y_train = Y(cv.training);
X_test = X(cv.test, :);
Y_test = Y(cv.test);
Mdl = fitcecoc(X_train, Y_train, 'Learners', templateSVM('KernelFunction', 'linear'));
handles.X_test=X_test;
handles.Y_test=Y_test;
handles.Mdl=Mdl;
helpdlg('Classifier is trained');
guidata(hObject, handles);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in readdingimgs.
function readdingimgs_Callback(hObject, eventdata, handles)
% hObject    handle to readdingimgs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('*************** Importing images *****************')
setpath=uigetdir;
path=fullfile(setpath);
imds = imageDatastore(path,"IncludeSubfolders",true,"FileExtensions",".png","LabelSource","foldernames");
z=imread(imds.Files{1,1});
labl=imds.Labels;
set(handles.edit1,'string',path);
handles.labl=labl;
handles.imds=imds;
handles.z=z;
helpdlg('Images are uploaded');
guidata(hObject, handles);

% --- Executes on button press in imagedis.
function imagedis_Callback(hObject, eventdata, handles)
% hObject    handle to imagedis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('*************** Sample images *****************')
imds=handles.imds;
perm = randperm(700,30);
for i = 1:30
    dd{i}=imds.Files{perm(i)};
end
figure,montage(dd)
title('sample images')
handles.imds=imds;
 helpdlg('Sample images diplayed');
 guidata(hObject, handles);
