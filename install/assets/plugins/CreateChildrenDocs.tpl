/**
 * Создание дочерних документов
 *
 * @category    plugin
 * @version     0.0.1a
 * @internal    @properties &jsonParams=json Params;string;
 * @internal    @events OnDocFormSave
 * @internal    @modx_category Manager and Admin
 * @internal    @installset base
 * @author      Andrew Lebedev (Redduck)
 * @lastupdate  26/03/2018
 */
if(!defined('MODX_BASE_PATH')) die('What are you doing? Get out of here!');
$default_field = array(
        'type'            => 'document',
        'contentType'     => 'text/html',
        'pagetitle'       => 'New document',
        'longtitle'       => '',
        'description'     => '',
        'alias'           => '',
        'link_attributes' => '',
        'published'       => 1,
        'pub_date'        => 0,
        'unpub_date'      => 0,
        'parent'          => 0,
        'isfolder'        => 0,
        'introtext'       => '',
        'content'         => '',
        'richtext'        => 1,
        'template'        => 0,
        'menuindex'       => 0,
        'searchable'      => 1,
        'cacheable'       => 1,
        'createdon'       => 0,
        'createdby'       => 0,
        'editedon'        => 0,
        'editedby'        => 0,
        'deleted'         => 0,
        'deletedon'       => 0,
        'deletedby'       => 0,
        'publishedon'     => 0,
        'publishedby'     => 0,
        'menutitle'       => '',
        'donthit'         => 0,
        'privateweb'      => 0,
        'privatemgr'      => 0,
        'content_dispo'   => 0,
        'hidemenu'        => 0,
        'alias_visible'   => 1
    );
$jsonParams = (isset($jsonParams))? $jsonParams : null;

$e = &$modx->event;
if ($e->name == 'OnDocFormSave') {
	//$modx->logEvent(1733, 1, $mode.' id = '.$id, 'CreateChildrenDocs');
	if (($mode == "new") && !empty($jsonParams)) {
		$jsonParams = str_replace("'", '"', $jsonParams);			
		$paramsObj = json_decode($jsonParams);
		if(json_last_error() === JSON_ERROR_NONE) {
			include_once(MODX_BASE_PATH."assets/lib/MODxAPI/modResource.php");
			$doc = new modResource($modx);
			$doc->edit($id);
			$parent = $doc->get('parent');
			$template = $doc->get('template');
			foreach($paramsObj as $k=>$v) {
				$Ch_bool = false;
				$parentDoc = $v->parentDoc;
				$templateDoc = $v->templateDoc;
				$children_docs = $v->docs;
				//$modx->logEvent(1733, 1, 'parent == '.$parentDoc.' template == '.$templateDoc,  'CreateChildrenDocs');
				if($parentDoc == $parent){
					if(!empty($templateDoc)) {
						if($templateDoc == $template){
							$Ch_bool = true;
						}
					} else {
						$Ch_bool = true;
					}
					if($Ch_bool) {
						foreach($children_docs AS $ck => $cv){
							$cvArr = (array) $cv;
							$cvArr['parent'] = $id;							
							$newDocArr = array_intersect_key($cvArr, $default_field);
							if((array_key_exists('pagetitle', $newDocArr) && !empty($newDocArr['pagetitle'])) && (array_key_exists('template', $newDocArr) && !empty($newDocArr['template']))) {
								$doc->create($newDocArr);
								$doc->save(false, true);
							} else {
								$modx->logEvent(1733, 1, 'Empty pagetitle or template',  'CreateChildrenDocs');
							}
						}
					}
				}
			}
		} else {
			$modx->logEvent(1733, 1, 'Error json_decode!',  'CreateChildrenDocs');
		}			
	}
}
