<script src="{$pluginJavaScriptURL}/optimetaCitations.js"></script>
<link rel="stylesheet" href="{$pluginStylesheetURL}/optimetaCitations.css" type="text/css" />

<script>
    var objOptimetaCitations = new OptimetaCitations();

    var optimetaCitationsJson = `{$citationsParsed}`;
    var optimetaCitations = JSON.parse(optimetaCitationsJson);

    var optimetaCitationsApp = new pkp.Vue({
        //el: '#optimetaCitations',
        data: {
            citations: optimetaCitations,
            helper: objOptimetaCitations.getHelperArray(optimetaCitations)
        },
        computed: {
            citationsJsonComputed: function() {
                return JSON.stringify(this.citations);
            }
        },
        methods: {
            addAuthor: function(event){
                alert('NOCH NICHT IMPLEMENTIERT!');
            }
        }
    });

    function enrichCitations(){
        let questionText = '{translate key="plugins.generic.optimetaCitationsPlugin.enrich.question"}';
        if (confirm(questionText) !== true) { return; }

        $.ajax({
            url: '{$pluginApiUrl}/enrich',
            method: 'POST',
            data: {
                submissionId: {$submissionId},
                citationsRaw: document.getElementById("citations-citationsRaw-control").value,
                citationsParsed: JSON.stringify(optimetaCitationsApp.citations)
            },
            headers: {
                'X-Csrf-Token': objOptimetaCitations.getCsrfToken(),
            },
            error(r) { },
            success(response) {
                optimetaCitations = JSON.parse(response['citationsParsed']);
                optimetaCitationsApp.citations = JSON.parse(response['citationsParsed']);
                optimetaCitationsApp.helper = objOptimetaCitations.getHelperArray(JSON.parse(response['citationsParsed']));
            }
        });
    }

    function submitCitations(){
        let questionText = '{translate key="plugins.generic.optimetaCitationsPlugin.submit.question"}';
        if (confirm(questionText) !== true) { return; }

        $.ajax({
            url: '{$pluginApiUrl}/submit',
            method: 'POST',
            data: {
                submissionId: {$submissionId},
                citationsRaw: document.getElementById("citations-citationsRaw-control").value,
                citationsParsed: JSON.stringify(optimetaCitationsApp.citations)
            },
            headers: {
                'X-Csrf-Token': objOptimetaCitations.getCsrfToken(),
            },
            error(r) { },
            success(response) {
                optimetaCitations = JSON.parse(response['citationsParsed']);
                optimetaCitationsApp.citations = JSON.parse(response['citationsParsed']);
                optimetaCitationsApp.helper = objOptimetaCitations.getHelperArray(JSON.parse(response['citationsParsed']));
            }
        });
    }

    function parseCitations(){
        let questionText = '{translate key="plugins.generic.optimetaCitationsPlugin.parse.question"}';
        if (confirm(questionText) !== true) { return; }

        $.ajax({
            url: '{$pluginApiUrl}/parse',
            method: 'POST',
            data: {
                submissionId: {$submissionId},
                citationsRaw: document.getElementById("citations-citationsRaw-control").value
            },
            headers: {
                'X-Csrf-Token': objOptimetaCitations.getCsrfToken(),
            },
            error(r) { },
            success(response) {
                optimetaCitations = JSON.parse(response['citationsParsed']);
                optimetaCitationsApp.citations = JSON.parse(response['citationsParsed']);
                optimetaCitationsApp.helper = objOptimetaCitations.getHelperArray(JSON.parse(response['citationsParsed']));
            }
        });
    }

    function copyToRaw(){
        let questionText =
            'Diese Methode überschreibt die RAW-Referenzen unter Literaturhinweise. ' +
            'NOCH NICHT IMPLEMENTIERT!';
        alert(questionText);
    }

</script>

<tab v-if="supportsReferences" id="optimetaCitations"
     label="{translate key="plugins.generic.optimetaCitationsPlugin.publication.label"}">

    <div class="header">
        <table>
            <tr>
                <td><h4>Citations</h4></td>
                <td>
                    <a href="javascript:copyToRaw()" id="buttonCopyToRaw"
                       class="pkpButton">Copy to RAW</a> &nbsp; &nbsp; &nbsp;
                    <a href="javascript:parseCitations()" id="buttonParse"
                       class="pkpButton">Parse</a>
                    <a href="javascript:enrichCitations()" id="buttonEnrich"
                       class="pkpButton">Enrich</a>
                    <a href="javascript:submitCitations()" id="buttonSubmit"
                       class="pkpButton">Submit</a>
                </td>
            </tr>
        </table>
    </div>

    <div class="optimetaScrollableDiv">
        <table>
            <colgroup>
                <col class="grid-column column-nr" style="width: 2%;">
                <col class="grid-column column-parts" style="">
                <col class="grid-column column-action" style="width: 6%;">
            </colgroup>
            <thead>
                <tr>
                    <th> # </th>
                    <th> </th>
                    <th> action </th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="(row, i) in optimetaCitationsApp.helper" class="optimetaRow">
                    <td>{{ i + 1 }}</td>
                    <td style="">
                        <div>
                            <span v-show="!row.editRow">
                                <a :href="optimetaCitationsApp.citations[i].doi"
                                   target="_blank">{{ optimetaCitationsApp.citations[i].doi }}</a></span>
                            <input id="doi-{{ i + 1 }}" placeholder="DOI" v-show="row.editRow"
                                   v-model="optimetaCitationsApp.citations[i].doi"
                                   class="optimetaInput" />

                            <span v-show="!row.editRow">
                                <a :href="optimetaCitationsApp.citations[i].urn"
                                   target="_blank">{{ optimetaCitationsApp.citations[i].urn }}</a></span>
                            <input id="urn-{{ i + 1 }}" placeholder="URN" v-show="row.editRow"
                                   v-model="optimetaCitationsApp.citations[i].urn"
                                   class="optimetaInput" />

                            <span v-show="!row.editRow">
                                <a :href="optimetaCitationsApp.citations[i].url"
                                   target="_blank">{{ optimetaCitationsApp.citations[i].url }}</a></span>
                            <input id="url-{{ i + 1 }}" placeholder="URL" v-show="row.editRow"
                                   v-model="optimetaCitationsApp.citations[i].url"
                                   class="optimetaInput" />
                        </div>

                        <div>

                            <div>
                                <span v-for="(author, j) in optimetaCitationsApp.citations[i].authors">
                                    <span v-show="!row.editRow" class="optimetaTag">{{ optimetaCitationsApp.citations[i].authors[j].display_name }}</span>
                                    <input id="display_name-{{ i + 1 }}-{{ j + 1 }}" placeholder="Author" v-show="row.editRow"
                                           v-model="optimetaCitationsApp.citations[i].authors[j].display_name"
                                           class="optimetaInput" />
                                    <input id="orcid-{{ i + 1 }}-{{ j + 1 }}" placeholder="Orcid" v-show="row.editRow"
                                           v-model="optimetaCitationsApp.citations[i].authors[j].orcid"
                                           class="optimetaInput" />
                                    <a class="optimetaButton optimetaButtonGreen"
                                       v-if="optimetaCitationsApp.citations[i].authors[j].orcid"
                                       :href="optimetaCitationsApp.citations[i].authors[j].orcid"
                                       target="_blank">iD</a>
                                    <br v-show="row.editRow"/>
                                </span>
                                <input id="display_name-{{ i + 1 }}-{{ j + 1 }}-new" placeholder="Author" v-show="row.editRow" class="optimetaInput" />
                                <input id="orcid-{{ i + 1 }}-{{ j + 1 }}-new" placeholder="Orcid" v-show="row.editRow" class="optimetaInput" />
                                <button v-show="row.editRow" v-on:click="optimetaCitationsApp.addAuthor()">Add</button>
                            </div>

                            <div>
                                <span v-show="!row.editRow && !optimetaCitationsApp.citations[i].isProcessed"
                                      class="optimetaTag">No information found</span>

                                <span v-show="!row.editRow && optimetaCitationsApp.citations[i].title"
                                      class="optimetaTag">{{ optimetaCitationsApp.citations[i].title }}</span>
                                <input id="title-{{ i + 1 }}" placeholder="Title" v-show="row.editRow" class="optimetaInput"
                                       v-model="optimetaCitationsApp.citations[i].title" />

                                <span v-show="!row.editRow && optimetaCitationsApp.citations[i].venue_display_name"
                                      class="optimetaTag">{{ optimetaCitationsApp.citations[i].venue_display_name }}</span>
                                <input id="venue_display_name-{{ i + 1 }}" placeholder="Venue" v-show="row.editRow" class="optimetaInput"
                                       v-model="optimetaCitationsApp.citations[i].venue_display_name" />

                                <span v-show="!row.editRow && optimetaCitationsApp.citations[i].publication_year"
                                      class="optimetaTag">{{ optimetaCitationsApp.citations[i].publication_year }}</span>
                                <input id="publication_year-{{ i + 1 }}" placeholder="Year" v-show="row.editRow" class="optimetaInput"
                                       v-model="optimetaCitationsApp.citations[i].publication_year" />

                                <span v-show="!row.editRow && optimetaCitationsApp.citations[i].volume"
                                      class="optimetaTag">Volume {{ optimetaCitationsApp.citations[i].volume }}</span>
                                <input id="volume-{{ i + 1 }}" placeholder="Volume" v-show="row.editRow" class="optimetaInput"
                                       v-model="optimetaCitationsApp.citations[i].volume" />

                                <span v-show="!row.editRow && optimetaCitationsApp.citations[i].issue"
                                      class="optimetaTag">Issue {{ optimetaCitationsApp.citations[i].issue }}</span>
                                <input id="issue-{{ i + 1 }}" placeholder="Issue" v-show="row.editRow" class="optimetaInput"
                                       v-model="optimetaCitationsApp.citations[i].issue" />

                                <span v-show="!row.editRow && optimetaCitationsApp.citations[i].first_page"
                                      class="optimetaTag">Pages {{ optimetaCitationsApp.citations[i].first_page }} - {{ optimetaCitationsApp.citations[i].last_page }}</span>
                                <input id="first_page-{{ i + 1 }}" placeholder="First page" v-show="row.editRow" class="optimetaInput"
                                       v-model="optimetaCitationsApp.citations[i].first_page" />
                                <input id="last_page-{{ i + 1 }}" placeholder="Last page" v-show="row.editRow" class="optimetaInput"
                                       v-model="optimetaCitationsApp.citations[i].last_page" />
                            </div>

                        </div>

                        <div class="optimetaRawText">{{ optimetaCitationsApp.citations[i].raw }}</div>

                        <div>
                            <a class="optimetaButton optimetaButtonGreen"
                               v-if="optimetaCitationsApp.citations[i].wikidata_qid"
                               :href="'https://www.wikidata.org/wiki/' + optimetaCitationsApp.citations[i].wikidata_qid"
                               target="_blank"><span>Wikidata</span></a>
                            <span class="optimetaButton optimetaButtonGrey"
                                  v-if="!optimetaCitationsApp.citations[i].wikidata_qid">Wikidata</span>
                            <a class="optimetaButton optimetaButton optimetaButtonGreen"
                               v-if="optimetaCitationsApp.citations[i].openalex_id"
                               :href="'https://openalex.org/' + optimetaCitationsApp.citations[i].openalex_id"
                               target="_blank"><span>OpenAlex</span></a>
                            <span class="optimetaButton optimetaButtonGrey"
                                  v-if="!optimetaCitationsApp.citations[i].openalex_id">OpenAlex</span>
                        </div>
                    </td>
                    <td class="optimetaScrollableDiv-actions">
                        <a v-show="!row.editRow"
                           v-on:click="row.editRow = !row.editRow"
                           class="pkpButton" label="Edit"> <i class="fa fa-pencil" aria-hidden="true"></i>
                        </a>
                        <a v-show="row.editRow"
                           v-on:click="row.editRow = !row.editRow"
                           class="pkpButton" label="Close"> <i class="fa fa-check" aria-hidden="true"></i>
                        </a>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>

    <div>
        <span style="display: none;">{{ components.OptimetaCitations_PublicationForm.fields[0]['value'] = optimetaCitationsApp.citationsJsonComputed }}</span>
        <pkp-form v-bind="components.{$smarty.const.OPTIMETA_CITATIONS_PUBLICATION_FORM}" @set="set"/>
    </div>

</tab>
