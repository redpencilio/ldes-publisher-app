alias Acl.Accessibility.Always, as: AlwaysAccessible
alias Acl.Accessibility.ByQuery, as: AccessByQuery
alias Acl.GraphSpec.Constraint.ResourceFormat, as: ResourceFormatConstraint
alias Acl.GraphSpec.Constraint.Resource, as: ResourceConstraint
alias Acl.GraphSpec, as: GraphSpec
alias Acl.GroupSpec, as: GroupSpec
alias Acl.GroupSpec.GraphCleanup, as: GraphCleanup
alias Acl.GraphSpec.Constraint.Resource.NoPredicates, as: NoPredicates
alias Acl.GraphSpec.Constraint.Resource.AllPredicates, as: AllPredicates

defmodule Acl.UserGroups.Config do
  def user_groups do
    # These elements are walked from top to bottom.  Each of them may
    # alter the quads to which the current query applies.  Quads are
    # represented in three sections: current_source_quads,
    # removed_source_quads, new_quads.  The quads may be calculated in
    # many ways.  The useage of a GroupSpec and GraphCleanup are
    # common.
    [
      # // PUBLIC
      %GroupSpec{
        name: "public",
        useage: [:read],
        access: %AlwaysAccessible{},
        graphs: [ %GraphSpec{
                    graph: "http://mu.semte.ch/graphs/public",
                    constraint: %ResourceConstraint{
                      resource_types: [
                        "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#FileDataObject",
                        "https://schema.org/SocialMediaPosting"
                      ]
                    } },
                  %GraphSpec{
                    graph: "http://mu.semte.ch/graphs/sessions",
                    constraint: %ResourceFormatConstraint{
                      resource_prefix: "http://mu.semte.ch/vocabularies/session/"
                    }
                  },
                  %GraphSpec{
                    graph: "http://mu.semte.ch/graphs/users",
                    constraint: %ResourceConstraint{
                      resource_types: [
                        "http://xmlns.com/foaf/0.1/OnlineAccount",
                        "http://xmlns.com/foaf/0.1/Person",
                      ]
                    }
                  }
                     ] },
      # Only logged in users can write a post
      %GroupSpec{
        name: "users",
        useage: [:read, :write, :read_for_write],
        access: %AccessByQuery{
          vars: ["account_id"],
          query: "PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
                  PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
                  PREFIX session: <http://mu.semte.ch/vocabularies/session/>
                  SELECT DISTINCT ?session_group WHERE {
                    <SESSION_ID> session:account ?account_id.
                    }" },
          graphs: [
            %GraphSpec{
              graph: "http://mu.semte.ch/graphs/users/",
              constraint: %ResourceConstraint{
                resource_types: [
                  "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#FileDataObject",
                  "https://schema.org/SocialMediaPosting",
                  "http://xmlns.com/foaf/0.1/OnlineAccount",
                  "http://xmlns.com/foaf/0.1/Person",
                ]
              } }
          ]
      },

      # // CLEANUP
      #
      %GraphCleanup{
        originating_graph: "http://mu.semte.ch/application",
        useage: [:write],
        name: "clean"
      }
    ]
  end
end
