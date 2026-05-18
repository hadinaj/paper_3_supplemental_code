# Conceptual Model Representation Notes

This document records representation decisions used to translate the supporting mapping files, relationship-assessment outputs, and schema representations into conceptual model views for the MIMIC-IV Demo hospital-module application.

The notes are intended to support traceability between the repository documentation and the conceptual model artifact. They explain how candidate entities, reference structures, detail/workflow-specific structures, selected source-derived attributes, candidate identifiers and linking fields, conceptual attribute groups, and relationship-assessment categories, including fully complete inferred, partially complete inferred, and context-dependent candidate relationships, are represented across the model views.

The model views are entity–relationship-style conceptual representations. They are reviewable and revisable artifacts, not implementation schemas, complete relationship-discovery outputs, declared primary-key/foreign-key specifications, or stakeholder-validated models.

## Supporting files and outputs used

| Supporting file or output | Role in model representation |
|---|---|
| `01_documentation_informed_relationship_check_assumptions.md` | Documents the assumptions used to define candidate relationship checks. |
| `02_conceptual_entity_mapping.md` | Provides table-level interpretation, modeling roles, and conceptual entity or structure names. |
| `03_source_to_concept_attribute_dictionary.csv` | Provides column-level conceptual attributes, conceptual attribute groups, attribute modeling roles, and attribute modeling treatments. |
| Relationship-assessment outputs | Inform relationship notation and relationship review status. |
| DBML/schema representations | Provide source-oriented schema views used as intermediate traceability artifacts. |

## Representation rules

| Model element | How it is represented | Based on |
|---|---|---|
| Candidate entity | Shown as a rectangle with the conceptual entity or structure label. | `02_conceptual_entity_mapping.md` |
| Reference entity | Shown as a distinct entity where a dictionary, code-definition, item-definition, provider, or other reference structure is needed to interpret coded, item-based, or identifier-based records. | `02_conceptual_entity_mapping.md` |
| Detail/workflow-specific structure | Retained as a separate structure when the source structure has its own workflow meaning, identifier, source granularity, or supporting detail role. | `02_conceptual_entity_mapping.md` |
| Candidate identifier or linking field | Shown where needed for traceability. Candidate identifiers and linking fields are not necessarily formally declared primary keys or foreign keys. | `03_source_to_concept_attribute_dictionary.csv`; relationship-assessment outputs |
| Selected source-derived attribute | Represented directly, grouped, or retained in supporting documentation depending on its role in the initial mapping. Not all source columns are shown in every model view. | `03_source_to_concept_attribute_dictionary.csv` |
| Conceptual attribute group | Related source columns are organized under proposed initial group labels to reduce visual clutter while preserving source-column traceability. These groups can be regrouped, renamed, or revised during later modeling or stakeholder-review steps. | `03_source_to_concept_attribute_dictionary.csv` |
| Fully complete inferred relationship | Shown as a solid relationship line when the evaluated link is fully supported by the relationship-assessment counts. | Relationship-assessment outputs |
| Partially complete inferred relationship | Shown as an inferred relationship with caution or visual distinction when the evaluated link is supported where present but not populated for all source rows. | Relationship-assessment outputs |
| Context-dependent candidate relationship | Shown as a reviewable/non-solid relationship line when the evaluated link requires contextual interpretation, including cases with unmatched non-null source values. | Relationship-assessment outputs |
| Conceptual attribute group view | Uses rectangles for candidate entities or structures and ovals for conceptual attribute groups. This view illustrates how source-column detail can be organized without overloading the main relationship-focused view. | `03_source_to_concept_attribute_dictionary.csv` |

## Interpretation limits

The conceptual model views should be interpreted as source-traceable and stakeholder-reviewable representations of candidate source-data concepts, selected attributes, identifiers, linking fields, and relationships. They are intended to make modeling assumptions and source-to-concept decisions visible for review.

The views should not be interpreted as finalized clinical ontologies, implementation schemas, complete relationship-discovery outputs, declared database constraints, or stakeholder-validated models. Different organizational uses may require different views of the same underlying mapping content, such as relationship-focused views, entity–identifier views, source-coverage views, or grouped-attribute views.
