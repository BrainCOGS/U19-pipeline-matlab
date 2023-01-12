% This scripts ingest into tables AnimalTemplate and DailyInfoTemplate

load('data/templates.mat', 'templates')



[templates.Genotype.template_name] = deal('Genotype');

% Template Animal
field_names = fetch1(reference.Template & 'template_name="Animal"', ...
                     'database_field_names');
[templates.Animal([11,12,14]).grouping] = deal('');
fields = cell2struct(struct2cell(templates.Animal), field_names);
[fields.template_name] = deal('Animal');
inserti(reference.TemplateAnimal, fields)


% Template DailyInfo
field_names = fetch1(reference.Template & 'template_name="DailyInfo"', ...
                     'database_field_names');                 
[templates.DailyInfo([4,5,24,25,30]).grouping] = deal('');
templates.DailyInfo(6).description = '';
fields = cell2struct(struct2cell(templates.DailyInfo), field_names);
[fields.template_name] = deal('DailyInfo');
inserti(reference.TemplateDailyInfo, fields)

% Template RightNow
[templates.RightNow.template_name] = deal('RightNow');
inserti(reference.TemplateRightNow, templates.RightNow)


% Template Genotype
[templates.Genotype.template_name] = deal('Genotype');
inserti(reference.TemplateGenotype, templates.Genotype)


% Template ActionItem
[templates.ActionItems.template_name] = deal('ActionItems');
inserti(reference.TemplateActionItems, templates.ActionItems)
    
    
    
    